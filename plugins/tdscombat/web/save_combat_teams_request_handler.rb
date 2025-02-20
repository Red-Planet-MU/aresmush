module AresMUSH
  module TDSCombat
    class SaveCombatTeamsRequestHandler
      def handle(request)
        id = request.args[:id]
        enactor = request.enactor
        
        error = Website.check_login(request)
        return error if error
        
        combat = Combat[id]
        if (!combat)
          return { error: t('tdscombat.invalid_combat_number') }
        end
        
        if (combat.turn_in_progress)
          return { error: t('tdscombat.turn_in_progress') }
        end

        combatants = request.args[:combatants]
        combatants.each do |key, combatant_data|
          
          combatant = Combatant[combatant_data[:id]]
          
          if (!combatant)
            return { error: t('tdscombat.not_in_combat', :name => combatant_data[:name])}
          end
          
          team = combatant_data[:team].to_i
          
          if (team != combatant.team)
            TDSCombat.change_team(combat, combatant, enactor, team)
          end
          
        
          if (error)
            return { error: "Error saving #{combatant.name}: #{error}" }
          end
        end
                    
        {
        }
      end
    end
  end
end


