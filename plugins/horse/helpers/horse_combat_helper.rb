module AresMUSH
  module Horse

    def self.horse_new_turn(combatant)
      #Check if mounted
      Global.logger.debug "combatant.mount_type: #{combatant.mount_type}"
      if (combatant.mount_type) 
        #Get the spook rating
        spook_rating = Global.read_config('horse', 'spook_rating')
        going_to_spook = rand(1...spook_rating)
        
        Global.logger.debug "going_to_spook: #{going_to_spook}, spook_rating: #{spook_rating}"
        if going_to_spook == spook_rating 
          FS3Combat.emit_to_combat combatant.combat, t('horse.going_to_spook', :name => combatant.name), nil, true
        end
        return 
      end
    end



  end
end
