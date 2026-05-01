module AresMUSH
  module FS3Combat
    class CalmAction < CombatAction
            
      def prepare
        return t('horse.not_mounted') if !self.combatant.mount_type
        if self.combatant.is_riding_with
          riding_with_spooked = self.combatant.is_riding_with.spook_counter
          return t('horse.not_spooked') if self.combatant.mount_type && self.combatant.spook_counter == 0 && !riding_with_spooked
        end
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
        if self.combatant.is_riding_with 
          riding_with_spooked = self.combatant.is_riding_with.spook_counter
          if riding_with_spooked
            main_rider = self.combatant.is_riding_with
            main_rider.update(spook_counter: 0)
            main_rider.update(calm_counter: 2)
          end
        end
        self.combatant.update(spook_counter: 0)
        self.combatant.update(calm_counter: 2)
        self.combatant.associated_model.update(horse_bond_counter: self.combatant.associated_model.horse_bond_counter + 1)
        #check whether to increment horse bond
        case self.combatant.associated_model.horse_bond_counter
        when 1
          self.combatant.associated_model.update(horse_bond: 1)
        when 3
          self.combatant.associated_model.update(horse_bond: 2)
        when 5
          self.combatant.associated_model.update(horse_bond: 3)
          trigger_job = true
        when 8
          self.combatant.associated_model.update(horse_bond: 4)
          trigger_job = true
        when 13
          self.combatant.associated_model.update(horse_bond: 5)
          trigger_job = true
        when 21
          self.combatant.associated_model.update(horse_bond: 6)
          trigger_job = true
        when 34
          self.combatant.associated_model.update(horse_bond: 7)
          trigger_job = true
        when 55
          self.combatant.associated_model.update(horse_bond: 8)
          trigger_job = true
        end
        if trigger_job == true
          message = t('horse.bond_raised_job', :name => self.combatant.associated_model.name, :rating => self.combatant.associated_model.horse_bond)
          status = Jobs.create_job(Jobs.system_category, t('horse.bond_job_title', :name => self.combatant.associated_model.name), message, Game.master.system_character)
          if (status[:job])
            Jobs.close_job(Game.master.system_character, status[:job])
          end
        end
        [t('horse.calm_resolution_msg', :name => self.name)]
      end
    end
  end
end