module AresMUSH
  module TDSCombat    
    class DamageCronHandler      
      def on_event(event)
        config = Global.read_config("tdscombat", "healing_cron")
        return if !Cron.is_cron_match?(config, event.time)
        
        Global.logger.debug "Time for healing."
        
        Character.all.each do |c|
          TDSCombat.heal_wounds(c)   
        end
        
        Healing.all.each do |h|
          if (TDSCombat.total_damage_mod(h.patient) == 0)
            h.delete
          end
        end
      end
    end
  end
end