module AresMUSH
  module TDSCombat
    class CombatSummaryRequestHandler
      def handle(request)
        id = request.args[:id]
        enactor = request.enactor
        
        error = Website.check_login(request, true)
        return error if error
        
        combat = Combat[id]
        if (!combat)
          return { error: t('tdscombat.invalid_combat_number') }
        end
        
        TDSCombat.build_combat_web_data(combat, enactor)
      end
    end
  end
end


