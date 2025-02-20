module AresMUSH
  module TDSCombat
    class CombatStanceCmd
      include CommandHandler
      include NotAllowedWhileTurnInProgress
      
      attr_accessor :names, :stance
      
      def parse_args
        if (cmd.args =~ /=/)
          args = cmd.parse_args(ArgParser.arg1_equals_arg2)
          self.names = list_arg(args.arg1)
          self.stance = titlecase_arg(args.arg2)
        else
          self.names = [enactor.name]
          self.stance = titlecase_arg(cmd.args)
        end
        
        if (self.stance)
          self.stance = TDSCombat.stances.keys.select { |s| s.start_with? self.stance }.first
        end
      end

      def required_args
        [ self.names ]
      end
      
      def check_stance        
        return t('tdscombat.invalid_stance') if !TDSCombat.stances.keys.include?(self.stance)
        return nil
      end
      
      def handle
        self.names.each do |name|
          TDSCombat.with_a_combatant(name, client, enactor) do |combat, combatant|        
            combatant.update(stance: stance)
            message = t('tdscombat.stance_changed', :stance => self.stance, :name => name, :poss => combatant.poss_pronoun)
            TDSCombat.emit_to_combat combat, message, TDSCombat.npcmaster_text(name, enactor)
          
            if (combatant.riding_in)
              client.emit_ooc t('tdscombat.passenger_stance_warning')
            end
          end
        end
      end
    end
  end
end