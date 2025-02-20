module AresMUSH
  module TDSSkills    
    class XpCronHandler
      def on_event(event)
        config = Global.read_config("tdsskills", "xp_cron")
        return if !Cron.is_cron_match?(config, event.time)
        
        Global.logger.debug "XP awards."
        
        periodic_xp = Global.read_config("tdsskills", "periodic_xp")
        max_xp = Global.read_config("tdsskills", "max_xp_hoard")
        
        approved = Chargen.approved_chars
        approved.each do |a|
          TDSSkills.modify_xp(a, periodic_xp)
        end
      end
    end    
  end
end