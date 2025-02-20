module AresMUSH
  module TDSCombat
    class PassAction < CombatAction
      
      def prepare
      end

      def print_action
        msg = t('tdscombat.pass_action_msg_long', :name => self.name)
      end
      
      def print_action_short
        t('tdscombat.pass_action_msg_short')
      end
      
      def resolve
        [t('tdscombat.pass_resolution_msg', :name => self.name)]
      end
    end
  end
end