module AresMUSH
  module TDSCombat
    class ReloadAction < CombatAction
      
      def prepare
        return t('tdscombat.cant_reload') if !self.combatant.max_ammo
        return nil
      end

      def print_action
        msg = t('tdscombat.reload_action_msg_long', :name => self.name)
      end
      
      def print_action_short
        t('tdscombat.reload_action_msg_short')
      end
            
      def resolve
        self.combatant.update(ammo: self.combatant.max_ammo)
        [t('tdscombat.reload_resolution_msg', :name => self.name)]
      end
    end
  end
end