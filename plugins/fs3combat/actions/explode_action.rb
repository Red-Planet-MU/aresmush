module AresMUSH
  module FS3Combat
    class ExplodeAction < CombatAction      
      def prepare
        weapon_type = FS3Combat.weapon_stat(self.combatant.weapon, "weapon_type")
        return t('fs3combat.not_explosive_weapon') if weapon_type != "Explosive"
        
        error = self.parse_targets(self.action_args)
        return error if error
      
        return t('fs3combat.too_many_targets') if (self.targets.count > 3)
      
        return t('fs3combat.out_of_ammo') if !FS3Combat.check_ammo(self.combatant, 1)
        
        return nil
      end
      
      def print_action
        t('fs3combat.explode_action_msg_long', :name => self.name, :targets => print_target_names)
      end
      
      def print_action_short
        t('fs3combat.explode_action_msg_short', :targets => print_target_names)
      end
      
      def resolve
        messages = []
        if FS3Combat.weapon_stat(self.combatant.weapon, "trap_type") == "Explosives"
          is_trap = true
        else
          is_trap = false
        end
        
        if is_trap == true
          ability = FS3Combat.weapon_stat(combatant.weapon, "skill")
          if combatant.is_npc? == false then
            #Find if weapon has specialty to add to attack roll
            firearm_specialty = FS3Combat.weapon_stat(combatant.weapon, "firearm_type")
            trapping_specialty = FS3Combat.weapon_stat(combatant.weapon, "trap_type")
            #then need to find if character has that specialty
            combatant_specialty = FS3Skills.find_specialty(combatant.character, ability)
        
            #If weapon and character's specialty match then give a 1 boost to attack roll
            if firearm_specialty == combatant_specialty || trapping_specialty == combatant_specialty then specialty_mod = 1
            else
              specialty_mod = 0
            end
          else specialty_mod = 0
          end
          botch_roll = combatant.roll_ability(ability, specialty_mod)
          successes = TDD.get_success_level(botch_roll)
          if successes < 0
            messages << t('fs3combat.explode_self_message', :name => self.name, :weapon => self.combatant.weapon)
            messages.concat FS3Combat.resolve_explosion(combatant, combatant)
            messages
          end
        else
          messages << t('fs3combat.explode_resolution_message', :name => self.name, :weapon => self.combatant.weapon)
        
          self.targets.each do |target, num|
            messages.concat FS3Combat.resolve_explosion(combatant, target)
          end

          ammo_message = FS3Combat.update_ammo(@combatant, 1)
          if (ammo_message)
            messages << ammo_message
          end
        
          messages
        end
      end
    end
  end
end