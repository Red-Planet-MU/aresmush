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
        case cmd.switch
        when "off"
          return LookingForRpOffCommand
        when "text"
          return LookingForRpTextCommand
        when "announce"
          return LookingForRpAnnounceCommand
        when nil
          return LookingForRpCommand
        end


      end
      nil
    end

    def self.get_web_request_handler(request)
      nil
    end

  end
end
