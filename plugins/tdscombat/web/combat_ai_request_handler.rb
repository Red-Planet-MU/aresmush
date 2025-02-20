module AresMUSH
  module TDSCombat
    class CombatAiActionsRequestHandler
      def handle(request)
        id = request.args[:id]
        enactor = request.enactor
        
        error = Website.check_login(request)
        return error if error
        
        combat = Combat[id]
        if (!combat)
          return { error: t('tdscombat.invalid_combat_number') }
        end
        
        if (!TDSCombat.can_manage_combat_from_web?(enactor, combat))
          return { error: t('dispatcher.not_allowed') }
        end        

        if (combat.turn_in_progress)
          return { error: t('tdscombat.turn_in_progress') }
        end

        npcs = combat.active_combatants.select { |c| c.is_npc? && !c.action }
        npcs.each_with_index do |c, i|
          TDSCombat.ai_action(combat, c, enactor)
        end
                    
        {
        }
      end
    end
  end
end


