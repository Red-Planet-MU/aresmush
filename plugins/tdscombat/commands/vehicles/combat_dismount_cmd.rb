module AresMUSH
  module TDSCombat
    class CombatDismountCmd
      include CommandHandler
      include NotAllowedWhileTurnInProgress
      
      attr_accessor :name
      
      def parse_args
        if (cmd.args)
          self.name = titlecase_arg(cmd.args)
        else
          self.name = enactor.name
        end
      end

      def required_args
        [ self.name ]
      end      
      
      def check_mounts_allowed
        return t('tdscombat.mounts_disabled') if !TDSCombat.mounts_allowed?
        return nil
      end
      
      def handle
        TDSCombat.with_a_combatant(name, client, enactor) do |combat, combatant|    
          if (combatant.mount_type)                
            combatant.update(mount_type: nil)
            TDSCombat.emit_to_combat combat, t('tdscombat.dismounted', :name => combatant.name)
          else
            client.emit_failure t('tdscombat.not_mounted')
          end
          
        end
      end
    end
  end
end