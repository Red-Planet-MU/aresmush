module AresMUSH
  module FS3Combat
    class EscapeAction < CombatAction
      
      def prepare
        return t('fs3combat.not_subdued') if !self.combatant.is_subdued? && !self.combatant.is_snared
        return nil
      end

      def print_action
        t('fs3combat.escape_action_msg_long', :name => self.name, :target => self.subduer_name)
      end
      
      def print_action_short
        t('fs3combat.escape_action_msg_short', :target => self.subduer_name)
      end
      
      def subduer_name
        if self.combatant.subdued_by 
          self.combatant.subdued_by.name 
        else
          self.combatant.snared_by.name
      end
      
      def subduer
        if self.combatant.subdued_by 
          self.combatant.subdued_by
        else 
          self.combatant.snared_by
      end
      
      def reset_subdue
        self.combatant.update(subdued_by: nil)
        self.combatant.update(action_klass: nil)
        self.combatant.update(action_args: nil)
      end
      
      def resolve
        messages = []
        
        # If the subduer is no longer subduing, you succeed automatically
        if (!self.combatant.is_subdued? && !self.combatant.is_snared)
          reset_subdue
          messages << t('fs3combat.escape_action_success', :name => self.name, :target => self.subduer_name)
        else  
          # This is a little different because it forces the attacker to make another subdue roll.  This
          # ensures that we use the attacker's melee weapon skill and not the defender's weapon
          if !self.combatant.is_snared
            margin = FS3Combat.determine_attack_margin(self.subduer, self.combatant)
            if (margin[:hit])
              messages << t('fs3combat.escape_action_failed', :name => self.name, :target => self.subduer_name)
            else
              messages << t('fs3combat.escape_action_success', :name => self.name, :target => self.subduer_name)
              self.reset_subdue
            end
          else 
            margin = self.combatant.snare_roll - self.combatant.roll_ability(athletics)
            if margin >= 0 
              messages << t('fs3combat.escape_action_failed', :name => self.name, :target => self.subduer_name)
            else
              messages << t('fs3combat.escape_action_success', :name => self.name, :target => self.subduer_name)
              self.combatant.update(is_snared: false)
              self.combatant.update(snared_by: nil)
              self.combatant.update(snare_roll: 0)
            end
          end
        end
        
        messages
      end
    end
  end
end