module AresMUSH
  module TDSCombat
    class CombatStartCmd
      include CommandHandler
      
      attr_accessor :type
      
      def parse_args
        self.type = cmd.args ? titlecase_arg(cmd.args) : "Real"
      end
      
      def check_mock
        types = ['Mock', 'Real']
        return nil if !self.type
        return t('tdscombat.invalid_combat_type', :types => types.join(" ")) if !types.include?(self.type)
        return nil
      end
      
      def check_not_already_in_combat
        return t('tdscombat.you_are_already_in_combat') if enactor.is_in_combat?
        return nil
      end
      
      def handle
        is_real = self.type == "Real"
        combat = Combat.create(:organizer => enactor, :is_real => is_real)
        TDSCombat.join_combat(combat, enactor.name, "Observer", enactor, client)
        
        message = is_real ? "tdscombat.start_real_combat" : "tdscombat.start_mock_combat"
        
        client.emit_ooc t(message, :num => combat.id)
      end
    end
  end
end