# require 'byebug'
module AresMUSH
  module Serum

    def self.serum_new_turn(combatant)
      Global.logger.debug "serum counter: #{combatant.serum_duration_counter}"
      if combatant.serum_duration_counter == 0
        #Get the lethality + init mod numbers to preserve a GM's set mod number
        lethal_mod = Global.read_config('serum',combatant.last_serum,'lethality_mod')
        init_mod = Global.read_config('serum',combatant.last_serum,'init_mod')
        combatant.update(serum_init_mod: 0)
        combatant.update(serum_damage_lethality_mod: 0)
        combatant.update(serum_lethality_mod: 0)
        combatant.update(serum_armor_mod: 0)
        combatant.update(serum_duration_counter: -1)
        combatant.log "#{combatant.name} resetting all serum mods."
        FS3Combat.emit_to_combat combatant.combat, t('serum.serum_wore_off', :name => combatant.name, :serum_name => combatant.last_serum.name), nil, true
        return 
      elsif combatant.serum_duration_counter > 0
        combatant.update(serum_duration_counter: combatant.serum_duration_counter - 1)
        return
      end
    end



  end
end
