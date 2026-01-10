module AresMUSH
  module FS3Combat
    class SnareAction < CombatAction
      
      def prepare
        weapon_type = FS3Combat.weapon_stat(self.combatant.weapon, "weapon_type")
        #LASSO
        damage_type = FS3Combat.weapon_stat(self.combatant.weapon, "damage_type")
        Global.logger.debug "damage type: #{damage_type}"
        return t('fs3combat.snares_only') if damage_type != "Stun" && weapon_type != "Melee" 
        #/LASSO
        
        error = self.parse_targets(self.action_args)
        return error if error
      
        return t('fs3combat.only_one_target') if (self.targets.count > 1)

        return t('fs3combat.already_snared') if (self.target.is_snared == true)
        
        return nil
      end

      def print_action
        t('fs3combat.snare_action_msg_long', :name => self.name, :target => print_target_names)
      end
      
      def print_action_short
        t('fs3combat.snare_action_msg_short', :target => print_target_names)
      end
      
      def resolve
        messages = []
        
        #if (target.subdued_by == self.combatant)
        #  messages << t('fs3combat.continues_subduing', :name => self.name, :target => print_target_names)
        #  return messages
        #end
        #if FS3Combat.weapon_stat(self.combatant.weapon, "damage_type") == "Stun"
        #  is_snare = true
        #  if FS3Skills.find_specialty(self.combatant.character, "Trapping") == "Snares"
        #  snare_spec_boost = 1
        #  else 
        #  snare_spec_boost = 0
        #  end
        #  Global.logger.debug "snare_spec_boost: #{snare_spec_boost}"
        #end


        #margin = FS3Combat.determine_attack_margin(self.combatant, target, snare_spec_boost)
        margin = FS3Combat.determine_attack_margin(self.combatant, target)
        if (margin[:hit])
          target.update(snared_by: self.combatant)
          target.update(is_snared: true)
          target.update(snare_roll: margin[:attacker_net_successes])
          messages << t('fs3combat.snare_action_success', :name => self.name, :target => print_target_names)
          #self.combatant.update(action_klass: nil)
          #self.combatant.update(action_args: nil)
          Global.logger.debug "target.snare_roll: #{target.snare_roll}"
        else
          messages << t('fs3combat.snare_action_failed', :name => self.name, :target => print_target_names)
        end
        
        messages
      end
    end
  end
end