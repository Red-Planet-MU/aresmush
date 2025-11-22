module AresMUSH
  module Horse

    def self.horse_new_turn(combatant)
      #Check if mounted and unspooked
      if (combatant.mount_type && combatant.spook_counter == 0)
        #Get the spook rating
        spook_rating = Global.read_config('horse', 'spook_rating')
        going_to_spook = rand(1...spook_rating+1)
        
        Global.logger.debug "going_to_spook: #{going_to_spook}, spook_rating: #{spook_rating}"
        #Check if random number matches spook rating
        if going_to_spook == spook_rating 
          FS3Combat.emit_to_combat combatant.combat, t('horse.going_to_spook', :name => combatant.name), nil, true
          combatant.update(spook_counter: 1)
        end
        return 
      #Check if mounted and already spooked
      elsif (combatant.mount_type && combatant.spook_counter > 0)
        #Odds begin at 1 in 5
        thrown_check = rand(1...7-combatant.spook_counter)
        if thrown_check == 1
          FS3Combat.emit_to_combat combatant.combat, t('horse.spook_thrown', :name => combatant.name), nil, true
          combatant.update(mount_type: nil)
        else 
        FS3Combat.emit_to_combat combatant.combat, t('horse.still_spooking', :name => combatant.name), nil, true
        combatant.update(spook_counter: spook_counter + 1)
        end
      end
    end



  end
end
