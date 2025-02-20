module AresMUSH
  module TDSCombat
    class CombatSetupRequestHandler
      def handle(request)
        id = request.args[:id]
        enactor = request.enactor
        
        error = Website.check_login(request)
        return error if error
        
        combat = Combat[id]
        if (!combat)
          return { error: t('tdscombat.invalid_combat_number') }
        end
        
        can_manage = TDSCombat.can_manage_combat_from_web?(enactor, combat)
        if (!can_manage)
          return { error: t('dispatcher.not_allowed') }
        end        
        
        combatants = {}
        actions = TDSCombat.action_klass_map.keys.sort
        actions.unshift "ai action"
        
        combat.active_combatants.sort_by { |c| c.name }.each do |c|
          combatants[c.id] = { 
                  id: c.id,
                  team: c.team,
                  name: c.name,
                  is_npc: c.is_npc?,
                  weapon: c.weapon_name,
                  weapon_specials: AresMUSH::TDSCombat.weapon_specials.keys.map { |k| {
                    name: k,
                    selected: (c.weapon_specials || []).include?(k)
                  }},
                  armor: c.armor_name,
                  armor_specials: AresMUSH::TDSCombat.armor_specials.keys.map { |k| {
                    name: k,
                    selected: (c.armor_specials || []).include?(k)
                  }},
                  stance: c.stance,
                  npc_skill:  c.is_npc? ? c.npc.level : nil,
                  action: TDSCombat.find_action_name(c.action_klass),
                  action_args: c.action_args,
                  vehicle: c.vehicle ? c.vehicle.name : "" ,
                  passenger_type: c.vehicle ? (c.piloting ? 'pilot' : 'passenger') : 'none'
                  
              }
            end
        
        {
          id: id,
          organizer: combat.organizer.name,
          can_manage: can_manage,
          combatant_types: TDSCombat.combatant_types.keys,
          combatants: combatants,
          options: {
            weapons: AresMUSH::TDSCombat.weapons.keys.sort,
            weapon_specials: AresMUSH::TDSCombat.weapon_specials.keys.sort,
            armor_specials:  AresMUSH::TDSCombat.armor_specials.keys.sort,
            armor: AresMUSH::TDSCombat.armors.keys.sort,
            stances: TDSCombat.stances.keys,
            npc_skills: TDSCombat.npc_type_names,
            actions: actions,
            targets: combat.active_combatants.map { |c| c.name }            
          }
        }
      end
    end
  end
end


