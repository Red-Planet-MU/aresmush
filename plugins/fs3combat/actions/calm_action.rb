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
        self.combatant.update(just_calmed: true)
        self.combatant.associated_model.update(horse_bond_counter: self.combatant.associated_model.horse_bond_counter + 1)
        #check whether to increment horse bond
        case self.combatant.associated_model.horse_bond_counter
        when 3
          self.combatant.associated_model.update(horse_bond: 1)
        when 5
          self.combatant.associated_model.update(horse_bond: 2)
        when 8
          self.combatant.associated_model.update(horse_bond: 3)
        when 13
          self.combatant.associated_model.update(horse_bond: 4)
        when 21
          self.combatant.associated_model.update(horse_bond: 5)
        when 34
          self.combatant.associated_model.update(horse_bond: 6)
        when 55
          self.combatant.associated_model.update(horse_bond: 7)
        when 89
          self.combatant.associated_model.update(horse_bond: 8)
        end
        [t('horse.calm_resolution_msg', :name => self.name)]
      end
    end
  end
end