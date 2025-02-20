module AresMUSH
  module TDSCombat
    class CombatTargetsCmd
      include CommandHandler
      
      def handle
        combat = TDSCombat.combat(enactor.name)
        if (!combat)
          client.emit_failure t('tdscombat.you_are_not_in_combat')
          return
        end
        
        if (combat.organizer != enactor)
          client.emit_failure t('tdscombat.only_organizer_can_do')
          return
        end
        
        template = CombatTargetsTemplate.new(combat)
        client.emit template.render
      end
    
    end
  end
end