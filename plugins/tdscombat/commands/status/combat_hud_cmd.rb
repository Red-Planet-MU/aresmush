module AresMUSH
  module TDSCombat
    class CombatHudCmd
      include CommandHandler
      
      def handle
        combat = TDSCombat.combat(enactor.name)
        if (!combat)
          client.emit_failure t('tdscombat.you_are_not_in_combat')
          return
        end
        
        template = CombatHudTemplate.new(combat)
        client.emit template.render
      end
    end
  end
end