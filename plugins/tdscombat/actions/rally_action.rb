module AresMUSH
  module TDSCombat
    class RallyAction < CombatAction
      
      def prepare
        error = self.parse_targets( self.action_args)
        return error if error
        
        return t('tdscombat.only_one_target') if (self.targets.count > 1)
        
        if (!self.target.is_ko)
          return t('tdscombat.target_not_koed')
        end
        
        return nil
      end
      
      def print_action
        msg = t('tdscombat.rally_action_msg_long', :name => self.name, :target => print_target_names)
      end
      
      def print_action_short
        t('tdscombat.rally_action_msg_short', :name => self.name, :target => print_target_names)
      end
      
      def resolve
        TDSCombat.check_for_unko(self.target)
        if (self.target.is_ko)
          message = t('tdscombat.rally_resolution_failed', :target => print_target_names, :name => self.name)
          if (!self.combatant.is_npc?)
            Achievements.award_achievement(self.combatant.associated_model, "fs3_rallied")  
          end
        else
          message = t('tdscombat.rally_resolution_success', :target => print_target_names, :name => self.name)
        end
        
        [ message ]
      end
    end
  end
end