module AresMUSH
  module TDSCombat
    class CombatNewTurnCmd
      include CommandHandler
      include NotAllowedWhileTurnInProgress

      def handle
        if (!enactor.is_in_combat?)
          client.emit_failure t('tdscombat.you_are_not_in_combat')
          return
        end
                
        combat = enactor.combat
        
        if (!TDSCombat.can_manage_combat?(enactor, combat))        
          client.emit_failure t('tdscombat.only_organizer_can_do')
          return
        end
                
        TDSCombat.new_turn(enactor, combat)
      end
    end
  end
end