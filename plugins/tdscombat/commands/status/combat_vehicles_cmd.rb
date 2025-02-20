module AresMUSH
  module TDSCombat
    class CombatVehiclesCmd
      include CommandHandler
      
      def check_in_combat
        return t('tdscombat.you_are_not_in_combat') if !enactor.is_in_combat?
        return nil
      end
      
      def handle
        combat = enactor.combat
        template = CombatVehiclesTemplate.new(combat)
        client.emit template.render
      end
    end
  end
end