module AresMUSH
  module Fortune
    class FortuneCronEventHandler

      def on_event(event)
        fortune_cron = Global.read_config("fortune", "cron")
       if Cron.is_cron_match?(fortune_cron, event.time)

          chars = Chargen.approved_chars.select { |c| c.fortunes_told_lately > 0 }

          chars.each do |c|
            Global.logger.debug "Expiring fortune cooldown for #{c.name}"
            c.update(fortunes_told_lately: c.fortunes_told_lately - 1)
          end
        end
      end

    end
  end
end
