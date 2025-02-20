module AresMUSH
  module TDSCombat
    class SuppressAction < CombatAction      
      def prepare
        error = self.parse_targets(self.action_args)
        return error if error

        weapon_type = TDSCombat.weapon_stat(self.combatant.weapon, "weapon_type")
        is_automatic = TDSCombat.weapon_stat(self.combatant.weapon, "is_automatic")
        if (weapon_type == "Explosive" || weapon_type == "Suppressive" || is_automatic)
          return t('tdscombat.too_many_targets') if (self.targets.count > 3)
        else        
          return t('tdscombat.too_many_targets') if (self.targets.count > 1)
        end

        if (self.targets.count > 1)
          return t('tdscombat.not_enough_ammo_for_fullauto') if !TDSCombat.check_ammo(self.combatant, 8)
        else
          return t('tdscombat.out_of_ammo') if !TDSCombat.check_ammo(self.combatant, 1)
        end
        
        return nil
      end
      
      def print_action
        t('tdscombat.suppress_action_msg_long', :name => self.name, :targets => print_target_names)
      end
      
      def print_action_short
        t('tdscombat.suppress_action_msg_short', :targets => print_target_names)
      end
      
      def resolve
        messages = []
        
        self.targets.each do |target, num|
          composure = Global.read_config("tdscombat", "composure_skill")
          attack_roll = TDSCombat.roll_attack(self.combatant, target)
          defense_roll = target.roll_ability(composure)
          margin = attack_roll - defense_roll
          
          self.combatant.log "#{self.name} suppressing #{target.name}.  atk=#{attack_roll} def=#{defense_roll}"
          if (margin >= 0)
            target.add_stress(margin + 2)
            if (!self.combatant.is_npc?)
              Achievements.award_achievement(self.combatant.associated_model, "fs3_suppressed")  
            end
            
            messages << t('tdscombat.suppress_successful_msg', :name => self.name, 
               :target => target.name, :weapon => self.combatant.weapon)
          else
            messages << t('tdscombat.suppress_failed_msg', :name => self.name, 
               :target => target.name, :weapon => self.combatant.weapon)
          end
        end
        
        if (self.targets.count > 1)
          ammo = 8
        else
          ammo = 1
        end

        ammo_message = TDSCombat.update_ammo(@combatant, ammo)
        if (ammo_message)
          messages << ammo_message
        end
        
        messages
      end
    end
  end
end