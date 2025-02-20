module AresMUSH
  module TDSCombat
    class CombatMountCmd
      include CommandHandler
      include NotAllowedWhileTurnInProgress
      
      attr_accessor :name, :mount
      
      def parse_args
        if (cmd.args =~ /=/)
          args = cmd.parse_args(ArgParser.arg1_equals_arg2)
          self.name = titlecase_arg(args.arg1)
          self.mount = titlecase_arg(args.arg2)
        else
          self.name = enactor.name
          self.mount = titlecase_arg(cmd.args)
        end
      end

      def required_args
        [ self.name, self.mount ]
      end
      
      def check_mounts_allowed
        return t('tdscombat.mounts_disabled') if !TDSCombat.mounts_allowed?
        return nil
      end
      
      def check_valid_mount
        return t('tdscombat.invalid_mount') if !TDSCombat.mount(self.mount)
        return nil
      end
      
      def handle
        TDSCombat.with_a_combatant(name, client, enactor) do |combat, combatant|     
          if (combatant.is_in_vehicle?)
            client.emit_failure t('tdscombat.cant_be_in_both_vehicle_and_mount', :name => combatant.name)
            return
          end
             
          combatant.update(mount_type: self.mount)
          TDSCombat.emit_to_combat combat, t('tdscombat.mounted', :name => combatant.name, :mount => self.mount)
        end
      end
    end
  end
end