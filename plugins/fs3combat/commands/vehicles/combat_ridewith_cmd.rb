module AresMUSH
  module FS3Combat
    class CombatRidewithCmd
      include CommandHandler
      include NotAllowedWhileTurnInProgress
      
      attr_accessor :name, :mount, :target
      
      def parse_args
        if (cmd.args =~ /=/)
          args = cmd.parse_args(ArgParser.arg1_equals_arg2)
          self.name = titlecase_arg(args.arg1)
          self.target = titlecase_arg(args.arg2)
        else
          self.name = enactor.name
          self.target = titlecase_arg(cmd.args)
        end
      end

      def required_args
        [ self.name, self.target ]
      end
      
      def check_mounts_allowed
        return t('fs3combat.mounts_disabled') if !FS3Combat.mounts_allowed?
        return nil
      end
      

      #def check_mount_kod
      #  return t('fs3combat.horse_is_kod') if self.name.horse_kod == true
      #  return nil
      #end
      
      def handle
        FS3Combat.with_a_combatant(name, client, enactor) do |combat, combatant|     
          if (combatant.is_in_vehicle?)
            client.emit_failure t('fs3combat.cant_be_in_both_vehicle_and_mount', :name => combatant.name)
            return
          end

          if (combatant.mount_type) 
            client.emit_failure t('fs3combat.cant_be_mounted_and_ride')
            return
          end

          FS3Combat.with_a_combatant(target, client, enactor) do |combat2, combatant2|

            if !combatant2.mount_type 
              client.emit_failure t('fs3combat.not_mounted_to_ride')
              return
            end

            if combatant2.horse_kod == true
              client.emit_failure t('fs3combat.their_horse_is_kod')
            return
            end

            combatant.update(mount_type: combatant2.mount_type)
            combatant.update(is_riding_with: combatant2)
            combatant2.update(is_carrying: combatant)
            FS3Combat.emit_to_combat combat, t('fs3combat.riding', :name => combatant.name, :riding_with_name => combatant2.name)
          end
        end
      end
    end
  end
end