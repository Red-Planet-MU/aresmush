module AresMUSH
  module TDSCombat
    class FullautoAction < CombatAction      
      def prepare
        weapon_type = TDSCombat.weapon_stat(self.combatant.weapon, "weapon_type")
        return t('tdscombat.use_explode_command') if weapon_type == "Explosive"
        return t('tdscombat.use_suppress_command') if weapon_type == "Suppressive"
        
        error = self.parse_targets(self.action_args)
        return error if error
      
        return t('tdscombat.too_many_targets') if (self.targets.count > 3)
      
        supports_burst = TDSCombat.weapon_stat(self.combatant.weapon, "is_automatic")
        return t('tdscombat.burst_fire_not_allowed') if !supports_burst
        
        return t('tdscombat.not_enough_ammo_for_fullauto') if !TDSCombat.check_ammo(self.combatant, 8)
        
        return nil
      end
      
      def print_action
        t('tdscombat.fullauto_action_msg_long', :name => self.name, :targets => print_target_names)
      end
      
      def print_action_short
        t('tdscombat.fullauto_action_msg_short', :targets => print_target_names)
      end
      
      def resolve
        messages = []
        
        messages << t('tdscombat.fires_fullauto', :name => self.name, :targets => print_target_names)
        
        case self.targets.count
        when 1
          bullets_per_target = 8
        when 2
          bullets_per_target = 3
        when 3
          bullets_per_target = 1
        end
        
        self.targets.each do |target, num|
          bullets_per_target.times.each do |n|
            messages.concat TDSCombat.attack_target(combatant, target)
          end
        end

        ammo_message = TDSCombat.update_ammo(@combatant, 8)
        if (ammo_message)
          messages << ammo_message
        end
        
        messages
      end
    end
  end
end