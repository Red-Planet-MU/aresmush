module AresMUSH
  module Serum    
    class SerumCronHandler
      def on_event(event)
        config = Global.read_config("serum", "serum_cron")
        return if !Cron.is_cron_match?(config, event.time)
        
        Global.logger.debug "Serum distribution."
        
        periodic_serum = Global.read_config("serum", "periodic_serum")
        
        approved = Chargen.approved_chars
        approved.each do |a|
          Serum.modify_serum(a, periodic_serum, 1)
        end
      end
    end    
  end
end