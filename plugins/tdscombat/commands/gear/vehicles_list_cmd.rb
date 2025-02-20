module AresMUSH
  module TDSCombat
    class VehiclesListCmd
      include CommandHandler
      
      def check_vehicles_allowed
        return t('tdscombat.vehicles_disabled') if !TDSCombat.vehicles_allowed?
        return nil
      end
      
      def handle
        template = GearListTemplate.new TDSCombat.vehicles, t('tdscombat.vehicles_title')
        client.emit template.render
      end
    end
  end
end