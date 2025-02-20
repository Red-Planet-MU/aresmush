module AresMUSH
  module TDSCombat
    class CombatLogRequestHandler
      def handle(request)
        id = request.args[:id]
        enactor = request.enactor
        
        error = Website.check_login(request, true)
        return error if error
        
        combat = Combat[id]
        if (!combat)
          return { error: t('tdscombat.invalid_combat_number') }
        end
        
        if (combat.debug_log)
          list = combat.debug_log.combat_log_messages.sort_by(:timestamp).map { |l| "#{l.created_at} #{l.message}"}.reverse
        else
          list = []
        end
        
        {
          id: id,
          log: list.join("\r\n")
        }
      end
    end
  end
end


