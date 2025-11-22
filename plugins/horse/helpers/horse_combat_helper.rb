module AresMUSH
  module Horse

    def self.horse_new_turn(combatant)
      #Check if mounted and unspooked
      if (combatant.mount_type && combatant.spook_counter == 0)
        #Get the spook rating and horse bond
        spook_rating = Global.read_config('horse', 'spook_rating')
        bond_with_horse = combatant.associated_model.horse_bond
        going_to_spook = rand(1...spook_rating + 1 + (bond_with_horse/3))
        
        Global.logger.debug "going_to_spook: #{going_to_spook}, spook_rating: #{spook_rating}"
        #Check if random number matches spook rating
        if going_to_spook == spook_rating 
          FS3Combat.emit_to_combat combatant.combat, t('horse.going_to_spook', :name => combatant.name), nil, true
          combatant.update(spook_counter: -1)
        end
        return 
      #Check if mounted and already spooked
      elsif (combatant.mount_type && combatant.spook_counter < 0)
        riding_roll = combatant.roll_ability("Riding", combatant.spook_counter)
        Global.logger.debug "riding roll: #{riding_roll}"
        #Odds begin at 1 in 5
        if riding_roll <= 0
          FS3Combat.emit_to_combat combatant.combat, t('horse.spook_thrown', :name => combatant.name), nil, true
          combatant.update(mount_type: nil)
          combatant.update(spook_counter: 0)
        else 
        FS3Combat.emit_to_combat combatant.combat, t('horse.still_spooking', :name => combatant.name), nil, true
        combatant.update(spook_counter: combatant.spook_counter - 1)
        end
      end
    end



  end
end
