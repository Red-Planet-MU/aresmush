module AresMUSH
  module TDSCombat
    class AimAction < CombatAction
            
      def prepare
        error = parse_targets(self.action_args)
        return error if error
        
        return t('tdscombat.only_one_target') if (self.targets.count > 1)
        return nil
      end

      def print_action
        msg = t('tdscombat.aim_action_msg_long', :name => self.name, :target => self.print_target_names)
      end
      
      def print_action_short
        t('tdscombat.aim_action_msg_short', :name => self.name, :target => self.print_target_names)
      end
      
      def resolve
        self.combatant.update(aim_target: self.target)
        [t('tdscombat.aim_resolution_msg', :name => self.name, :target => self.print_target_names)]
      end
    end
  end
end