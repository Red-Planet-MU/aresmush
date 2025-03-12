# require 'byebug'
module AresMUSH
  module Serum

    def self.serum_new_turn(combatant)
      if combatant.serum_duration_counter == 0
        #Get the lethality + init mod numbers to preserve a GM's set mod number
        lethal_mod = Global.read_config('serum',combatant.associated_model.last_serum,'lethality_mod')
        init_mod = Global.read_config('serum',combatant.associated_model.last_serum,'init_mod')
        combatant.update(initiative_mod: combatant.initiative_mod - init_mod)
        combatant.update(damage_lethality_mod: combatant.damage_lethality_mod - lethal_mod)
        combatant.update(serum_lethality_mod: 0)
        combatant.update(serum_armor_mod: 0)
        combatant.log "#{combatant.name} resetting all serum mods."
        return 
      else
        combatant.update(serum_duration_counter: combatant.serum_duration_counter - 1)
        return
      end
    end



  end
end
