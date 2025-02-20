module AresMUSH
  module TDSCombat
    class SubdueAction < CombatAction
      
      def prepare
        weapon_type = TDSCombat.weapon_stat(self.combatant.weapon, "weapon_type")
        return t('tdscombat.subdue_uses_melee') if weapon_type != "Melee"
        
        error = self.parse_targets(self.action_args)
        return error if error
      
        return t('tdscombat.only_one_target') if (self.targets.count > 1)
        
        return nil
      end

      def print_action
        t('tdscombat.subdue_action_msg_long', :name => self.name, :target => print_target_names)
      end
      
      def print_action_short
        t('tdscombat.subdue_action_msg_short', :target => print_target_names)
      end
      
      def resolve
        messages = []
        
        if (target.subdued_by == self.combatant)
          messages << t('tdscombat.continues_subduing', :name => self.name, :target => print_target_names)
          return messages
        end
        
        margin = TDSCombat.determine_attack_margin(self.combatant, target)
        if (margin[:hit])
          target.update(subdued_by: self.combatant)
          target.update(action_klass: nil)
          target.update(action_args: nil)
          messages << t('tdscombat.subdue_action_success', :name => self.name, :target => print_target_names)
          if (!self.combatant.is_npc?)
            Achievements.award_achievement(self.combatant.associated_model, "fs3_subdued")  
          end
        else
          messages << t('tdscombat.subdue_action_failed', :name => self.name, :target => print_target_names)
        end
        
        messages
      end
    end
  end
end