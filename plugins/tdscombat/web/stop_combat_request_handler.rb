module AresMUSH
  module TDSCombat
    class StopCombatRequestHandler
      def handle(request)
        id = request.args[:id]
        enactor = request.enactor
        
        error = Website.check_login(request)
        return error if error
        
        request.log_request
        
        combat = Combat[id]
        if (!combat)
          return { error: t('webportal.not_found') }
        end

        if (!TDSCombat.can_manage_combat?(enactor, combat))
          return { error: t('dispatcher.not_allowed') }
        end

        if (combat.turn_in_progress)
          return { error: t('tdscombat.turn_in_progress') }
        end
        
        TDSCombat.emit_to_combat combat, t('tdscombat.combat_stopped_by', :name => enactor.name)
        combat.delete
        
        {
        }
      end
    end
  end
end


