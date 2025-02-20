module AresMUSH
  module TDSCombat
    class VehicleDetailCmd
      include CommandHandler
      
      attr_accessor :name
      
      def parse_args
        self.name = titlecase_arg(cmd.args)
      end

      def required_args
        [ self.name ]
      end
      
      def check_vehicles_allowed
        return t('tdscombat.vehicles_disabled') if !TDSCombat.vehicles_allowed?
        return nil
      end
      
      def check_vehicle_exists
        return t('tdscombat.invalid_vehicle') if !TDSCombat.vehicle(self.name)
        return nil
      end
      
      def handle
        template = GearDetailTemplate.new(TDSCombat.vehicle(self.name), self.name, :vehicle)
        client.emit template.render
      end
    end
  end
end