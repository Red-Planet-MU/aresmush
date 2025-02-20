module AresMUSH
  module TDSCombat
    
    def self.roll_attack(combatant, target, mod = 0)
      ability = TDSCombat.weapon_stat(combatant.weapon, "skill")
      accuracy_mod = TDSCombat.weapon_stat(combatant.weapon, "accuracy")
      special_mod = combatant.attack_mod
      damage_mod = combatant.total_damage_mod
      stance_mod = combatant.attack_stance_mod
      stress_mod = combatant.stress
      aiming_mod = (combatant.is_aiming? && (combatant.aim_target == combatant.action.target)) ? 3 : 0
      luck_mod = (combatant.luck == "Attack") ? 3 : 0

      if (combatant.mount_type && !target.mount_type)
        mount_mod = TDSCombat.mount_stat(combatant.mount_type, "mod_vs_unmounted")
      elsif (!combatant.mount_type && target.mount_type)
        mount_mod = 0 - TDSCombat.mount_stat(target.mount_type, "mod_vs_unmounted")
      else
        mount_mod = 0
      end

      combatant.log "Attack roll for #{combatant.name} ability=#{ability} aiming=#{aiming_mod} mod=#{mod} accuracy=#{accuracy_mod} damage=#{damage_mod} stance=#{stance_mod} mount=#{mount_mod} luck=#{luck_mod} stress=#{stress_mod} special=#{special_mod}"

      mod = mod + accuracy_mod + damage_mod + stance_mod + aiming_mod + luck_mod - stress_mod + special_mod + mount_mod
      
      
      combatant.roll_ability(ability, mod)
    end
    
    def self.roll_defense(combatant, attacker_weapon)
      ability = TDSCombat.weapon_defense_skill(combatant, attacker_weapon)
      stance_mod = combatant.defense_stance_mod
      luck_mod = (combatant.luck == "Defense") ? 3 : 0
      damage_mod = combatant.total_damage_mod
      special_mod = combatant.defense_mod
      dodge_mod = TDSCombat.vehicle_dodge_mod(combatant)
      armor_mod = TDSCombat.armor_stat(combatant.armor, 'defense') || 0
      
      mod = stance_mod + luck_mod + damage_mod + special_mod + dodge_mod + armor_mod
      
      combatant.log "Defense roll for #{combatant.name} ability=#{ability} stance=#{stance_mod} damage=#{damage_mod} luck=#{luck_mod} special=#{special_mod} armor=#{armor_mod} dodge=#{dodge_mod}"
      
      combatant.roll_ability(ability, mod)
    end
    
    def self.roll_strength(combatant)
      strength = Global.read_config("tdscombat", "strength_skill")
      combatant.roll_ability(strength)
    end
    
    # Attacker           |  Defender            |  Skill
    # -------------------|----------------------|----------------------------
    # Any weapon         |  In Vehicle          |  Vehicle piloting skill
    # Melee weapon       |  Melee weapon        |  Defender's weapon skill
    # Melee weapon       |  Other weapon        |  Default combatant type skill
    # Other weapon       |  Other weapon        |  Default combatant type skill
    def self.weapon_defense_skill(combatant, attacker_weapon)
      if (combatant.is_in_vehicle?)
        return TDSCombat.vehicle_stat(combatant.vehicle.vehicle_type, "pilot_skill")
      end
      
      attacker_weapon_type = TDSCombat.weapon_stat(attacker_weapon, "weapon_type").titlecase
      defender_weapon_type = TDSCombat.weapon_stat(combatant.weapon, "weapon_type").titlecase
      if (attacker_weapon_type == "Melee" && defender_weapon_type == "Melee")
        skill = TDSCombat.weapon_stat(combatant.weapon, "skill")
      else
        skill = TDSCombat.combatant_type_stat(combatant.combatant_type, "defense_skill") ||
                Global.read_config("tdscombat", "default_defense_skill")
      end
      skill
    end
    
    def self.hitloc_chart(combatant, crew_hit = false)
      vehicle = combatant.vehicle
      if (!crew_hit && vehicle)
        hitloc_type = vehicle.hitloc_type
      else
        hitloc_type = TDSCombat.combatant_type_stat(combatant.combatant_type, "hitloc")
      end
      TDSCombat.hitloc_chart_for_type(hitloc_type)
    end
    
    def self.hitloc_areas(combatant, crew_hit = false)
      TDSCombat.hitloc_chart(combatant, crew_hit)["areas"]
    end
    
    def self.has_hitloc?(combatant, hitloc, crew_hit = false)
      hitlocs = TDSCombat.hitloc_areas(combatant, crew_hit)
      hitlocs.keys.map { |h| h.titlecase }.include?(hitloc.titlecase)
    end
    
    def self.hitloc_severity(combatant, hitloc, crew_hit = false)
      hitloc_chart = TDSCombat.hitloc_chart(combatant, crew_hit)
      vital_areas = hitloc_chart["vital_areas"]
      crit_areas = hitloc_chart["critical_areas"]
      
      return "Vital" if vital_areas.map { |v| v.titlecase }.include?(hitloc.titlecase)
      return "Critical" if crit_areas.map { |c| c.titlecase }.include?(hitloc.titlecase)
      return "Normal"
    end
    
    def self.determine_hitloc(combatant, attacker_net_successes, called_shot = nil, crew_hit = nil)
      return called_shot if (called_shot && attacker_net_successes > 2)

      hitloc_chart = TDSCombat.hitloc_areas(combatant, crew_hit)
            
      if (called_shot)
        locations = hitloc_chart[called_shot]
      else
        locations = hitloc_chart[hitloc_chart.keys.first]
      end
      
      roll = rand(locations.count) + attacker_net_successes
      roll = [roll, locations.count - 1].min
      roll = [0, roll].max
      locations[roll]
    end    
      
    def self.roll_initiative(combatant, ability)
      luck_mod = combatant.luck == "Initiative" ? 3 : 0
      action_mod = 0
      if (combatant.action_klass == "AresMUSH::TDSCombat::SuppressAction" ||
          combatant.action_klass == "AresMUSH::TDSCombat::DistractAction" || 
          combatant.action_klass == "AresMUSH::TDSCombat::SubdueAction")
          action_mod = 3
      end
      weapon_mod = TDSCombat.weapon_stat(combatant.weapon, "init_mod") || 0
      gm_mod = combatant.initiative_mod
      roll = combatant.roll_ability(ability, weapon_mod + action_mod + luck_mod + combatant.total_damage_mod + gm_mod)

      combatant.log "Initiative roll for #{combatant.name} ability=#{ability} action=#{action_mod} weapon=#{weapon_mod} luck=#{luck_mod} gm=#{gm_mod} roll=#{roll}"
 
      roll
    end
    
    def self.check_ammo(combatant, bullets)
      return true if combatant.max_ammo == 0
      combatant.ammo >= bullets
    end
    
    def self.update_ammo(combatant, bullets)
      return nil if combatant.max_ammo == 0

      ammo = combatant.ammo - bullets
      combatant.update(ammo: ammo)
      
      if (ammo == 0)
        t('tdscombat.weapon_clicks_empty', :name => combatant.name)
      else
        nil
      end
    end
    
    def self.change_team(combat, combatant, enactor, team)
      combatant.update(team: team)
      name = combatant.name
      message = t('tdscombat.team_set', :name => name, :team => team)
      TDSCombat.emit_to_combat combat, message, TDSCombat.npcmaster_text(name, enactor)
    end
    
    def self.update_combatant(combat, combatant, enactor, team, stance, 
      weapon, selected_weapon_specials, armor, selected_armor_specials, npc_level, action, action_args,
      vehicle_name, passenger_type)
      
      if (team != combatant.team)
        combatant.update(team: team)
        TDSCombat.emit_to_combat combat, t('tdscombat.team_set', :name => combatant.name, :team => team ), TDSCombat.npcmaster_text(combatant.name, enactor)
      end
      
      if (stance != combatant.stance)
        combatant.update(stance: stance)
        TDSCombat.emit_to_combat combat, t('tdscombat.stance_changed', :name => combatant.name, :poss => combatant.poss_pronoun, :stance => stance), TDSCombat.npcmaster_text(combatant.name, enactor)
      end
      
      allowed_specials = TDSCombat.weapon_stat(weapon, "allowed_specials") || []
      weapon_specials = []
      selected_weapon_specials.each do |name|
        if (allowed_specials.include?(name))
          weapon_specials << name
        else
          return t('tdscombat.invalid_weapon_special', :special => name)
        end
      end
      
      if (combatant.weapon_name != weapon || combatant.weapon_specials != weapon_specials)
        TDSCombat.set_weapon(enactor, combatant, weapon, weapon_specials)
      end
      
      
      allowed_specials = TDSCombat.armor_stat(armor, "allowed_specials") || []
      armor_specials = []
      selected_armor_specials.each do |name|
        if (allowed_specials.include?(name))
          armor_specials << name
        else
          return t('tdscombat.invalid_armor_special', :special => name)
        end
      end
            
      if (armor != combatant.armor_name || combatant.armor_specials != armor_specials)
        TDSCombat.set_armor(enactor, combatant, armor, armor_specials)
      end
      
      if (combatant.is_npc? && combatant.npc.level != npc_level)
        combatant.npc.update(level: npc_level)
      end
      
      current_action = TDSCombat.find_action_name(combatant.action_klass)
      if (current_action != action || action_args != combatant.action_args)
        if (action == "ai action")
          TDSCombat.ai_action(combat, combatant, enactor)
        else
          new_action_klass = TDSCombat.find_action_klass(action)
          new_action = new_action_klass.new(combatant, action_args)
          error = new_action.prepare
          if (error)
            return error
          end
          combatant.update(action_klass: new_action_klass)
          combatant.update(action_args: action_args)
          TDSCombat.emit_to_combat combat, "#{new_action.print_action}", TDSCombat.npcmaster_text(combatant.name, enactor)
        end
      end
      
      current_passenger_type = combatant.vehicle ? (combatant.piloting ? 'pilot' : 'passenger') : 'none'
      current_vehicle_name = combatant.vehicle ? combatant.vehicle.name : ''
      
      if (vehicle_name != current_vehicle_name || passenger_type != current_passenger_type)
        if (combatant.vehicle)
          TDSCombat.leave_vehicle(combat, combatant)
        end
        if (passenger_type != 'none')
          joining_vehicle = combat.find_combatant(vehicle_name)
          if (joining_vehicle && joining_vehicle.vehicle)
            vehicle_name = joining_vehicle.vehicle.name
          end
        
          vehicle = TDSCombat.find_or_create_vehicle(combat, vehicle_name)
          if (!vehicle)
            return t('tdscombat.invalid_vehicle_name')
          end
          TDSCombat.join_vehicle(combat, combatant, vehicle, passenger_type.titlecase) 
        end
      end
      
      return nil
    end
  end
end