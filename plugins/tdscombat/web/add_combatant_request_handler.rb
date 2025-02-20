module AresMUSH
  module TDSCombat
    class AddCombatantRequestHandler
      def handle(request)
        id = request.args[:id]
        enactor = request.enactor
        combatant_type = request.args[:combatant_type] || TDSCombat.default_combatant_type
        names = (request.args[:name] || "").split(/[ ,]/)
        
        if (names.empty?)
          return { error: t('tdscombat.invalid_combatant_name')}
        end
        
        error = Website.check_login(request)
        return error if error
        
        combat = Combat[id]
        if (!combat)
          return { error: t('tdscombat.invalid_combat_number') }
        end
        
        names.each do |name|
          if (name.blank?)
            next
          end
          
          if (TDSCombat.is_in_combat?(name))
            return { error: t('tdscombat.already_in_combat', :name => name) }
          end
        
          combatant = TDSCombat.join_combat(combat, name, combatant_type, enactor, nil)
          if (!combatant) 
            return { error: t('tdscombat.already_in_combat', :name => name) }
          end
        end
        
        TDSCombat.build_combat_web_data(combat, enactor)
      end
    end
  end
end


