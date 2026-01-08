$:.unshift File.dirname(__FILE__)

module AresMUSH
     module Fortune

    def self.plugin_dir
      File.dirname(__FILE__)
    end

    def self.shortcuts
      Global.read_config("fortune", "shortcuts")
    end

    def self.get_cmd_handler(client, cmd, enactor)
      case cmd.root
      when 'fortune'
        return FortuneCommand


      end
      nil
    end

    def self.get_event_handler(event_name) 
      case event_name
      when "CronEvent"
        return FortuneCronEventHandler
      end
      nil
    end

    def self.get_web_request_handler(request)
      case request.cmd
      when "getFortune"
        return GetFortuneRequestHandler
      end
    end

    def self.achievements
      Global.read_config('fortune', 'achievements')
    end


  end
end
