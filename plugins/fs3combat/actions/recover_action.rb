module AresMUSH
  module FS3Combat
    class RecoverAction < CombatAction
      
      def prepare
        return t('fs3combat.cant_recover') if !self.combatant.max_throws
        return nil
      end

      def print_action
        msg = t('fs3combat.recover_action_msg_long', :name => self.name)
      end
      
      def print_action_short
        t('fs3combat.recover_action_msg_short')
      end
            
      def resolve
        self.combatant.update(throws: self.combatant.throws + 1)
        [t('fs3combat.recover_resolution_msg', :name => self.name)]
      end
    end
  end
end