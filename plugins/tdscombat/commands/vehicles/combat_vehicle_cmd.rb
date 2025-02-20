module AresMUSH
  module TDSCombat
    class CombatVehicleCmd
      include CommandHandler
      include NotAllowedWhileTurnInProgress
      
      attr_accessor :names, :vehicle, :passenger_type
      
      def parse_args
        if (cmd.args =~ /=/)
          args = cmd.parse_args(ArgParser.arg1_equals_arg2)
          self.names = titlecase_arg(args.arg1)
          self.vehicle = trim_arg(args.arg2)
        else
          self.names = enactor_name
          self.vehicle = titlecase_arg(cmd.args)
        end
        
        self.names = self.names ? self.names.split(/[ ,]/) : nil
        
        self.passenger_type = cmd.switch_is?("passenger") ? "Passenger" : "Pilot"
      end

      def required_args
        [ self.names, self.vehicle, self.passenger_type ]
      end
      
      def check_in_combat
        return t('tdscombat.you_are_not_in_combat') if !enactor.is_in_combat?
        return nil
      end
      
      def check_vehicles_allowed
        return t('tdscombat.vehicles_disabled') if !TDSCombat.vehicles_allowed?
        return nil
      end
      
      def handle
        combat = enactor.combat

        # Allow joining someone who's already in a vehicle by name.  It's not
        # actually the vehicle name, it's their name.
        combatant = combat.find_combatant(self.vehicle)
        if (combatant && combatant.vehicle)
          self.vehicle = combatant.vehicle.name
        end
        
        self.names.each do |name|
        
          vehicle = TDSCombat.find_or_create_vehicle(combat, self.vehicle) 
            
          if (!vehicle)
            client.emit_failure t('tdscombat.invalid_vehicle_name')
            return
          end
        
          TDSCombat.with_a_combatant(name, client, enactor) do |combat, combatant|

            if (combatant.mount_type)
              client.emit_failure t('tdscombat.cant_be_in_both_vehicle_and_mount', :name => combatant.name)
              return
            end
            
            if (combatant.is_in_vehicle?)
              TDSCombat.leave_vehicle(combat, combatant)
            end
            TDSCombat.join_vehicle(combat, combatant, vehicle, self.passenger_type)
          end
        end
      end
    end
  end
end