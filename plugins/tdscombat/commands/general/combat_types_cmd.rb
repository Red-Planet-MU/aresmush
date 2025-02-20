module AresMUSH
  module TDSCombat
    class CombatTypesCmd
      include CommandHandler
      
      def handle
        template = CombatTypesTemplate.new(TDSCombat.combatant_types)
        client.emit template.render
      end        
    end
  end
end