module AresMUSH
  module Fortune
    class FortuneCronEventHandler

      def on_event(event)
        fortune_cron = Global.read_config("fortune", "cron")
       if Cron.is_cron_match?(fortune_cron, event.time)
          Global.logger.debug "Expiring fortune cooldowns."

          chars = Fortune.chars_on_cooldown.select { |c| c.fortune_cooldown_expires_at < Time.now }

          chars.each do |c|
            Global.logger.debug "Expiring fortune cooldown for #{c.name}"
            Fortune.expire(c)
          end
        end
      end

    end
  end
end
