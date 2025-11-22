module AresMUSH
  module FS3Combat
    class CalmAction < CombatAction
            
      def prepare
        return t('horse.not_mounted') if !self.combatant.mount_type
        return t('horse.not_spooked') if self.combatant.mount_type && self.combatant.spook_counter == 0
        return nil
      end

      def print_action
        msg = t('horse.calm_action_msg_long', :name => self.name)
      end
      
      def print_action_short
        t('horse.calm_action_msg_short', :name => self.name)
      end
      
      def resolve
        self.combatant.update(spook_counter: 0)
        self.combatant.associated_model.update(horse_bond: self.combatant.associated_model.horse_bond + 1)
        [t('horse.calm_resolution_msg', :name => self.name)]
      end
    end
  end
end