module AresMUSH
  module TDSCombat
    class TreatAction < CombatAction
      
      def prepare
        error = self.parse_targets( self.action_args)
        return error if error
        
        return t('tdscombat.only_one_target') if (self.targets.count > 1)
                
        wound = TDSCombat.worst_treatable_wound(self.target.associated_model)
        if (!wound)
          return t('tdscombat.target_has_no_treatable_wounds', :name => self.target.name)
        end                
        
        if (self.target != self.combatant && !self.target.is_passing?)
          return t('tdscombat.patient_must_pass')
        end
        
        return nil
      end
      
      def print_action
        msg = t('tdscombat.treat_action_msg_long', :name => self.name, :target => print_target_names)
      end
      
      def print_action_short
        t('tdscombat.treat_action_msg_short', :name => self.name, :target => print_target_names)
      end
      
      def resolve
        message = TDSCombat.treat(self.target.associated_model, self.combatant.associated_model)
        TDSCombat.check_for_unko(self.target)
        if (!self.combatant.is_npc?)
          Achievements.award_achievement(self.combatant.associated_model, "fs3_treated")  
        end
        [message]
      end
    end
  end
end