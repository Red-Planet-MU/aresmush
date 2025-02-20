module AresMUSH
  module TDSCombat
    class CombatNpcCmd
      include CommandHandler
      include NotAllowedWhileTurnInProgress
      
      attr_accessor :level, :names
      
      def parse_args
        args = cmd.parse_args(ArgParser.arg1_equals_arg2)
        self.names = list_arg(args.arg1)
        self.level = titlecase_arg(args.arg2)
      end

      def required_args
        [ self.level ]
      end
      
      def check_reason
        levels = TDSCombat.npc_type_names
        return t('tdscombat.invalid_npc_level', :levels => levels.join(", ")) if !levels.include?(self.level)
        return nil
      end
      
      def handle
        self.names.each do |name|
          TDSCombat.with_a_combatant(name, client, enactor) do |combat, combatant|
          
            if (combat.organizer != enactor)
              client.emit_failure t('tdscombat.only_organizer_can_do')
              return
            end
          
            if (!combatant.is_npc?)
              client.emit_failure t('tdscombat.not_a_npc')
              return
            end

            combatant.npc.update(level: self.level)
            client.emit_success t('tdscombat.npc_skill_set', :name => name, :level => self.level)
          end
        end
      end
    end
  end
end