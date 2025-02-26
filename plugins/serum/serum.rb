$:.unshift File.dirname(__FILE__)

module AresMUSH
     module Serum

    def self.plugin_dir
      File.dirname(__FILE__)
    end

    def self.shortcuts
      Global.read_config("serum", "shortcuts")
    end

    def self.get_cmd_handler(client, cmd, enactor)
      case cmd.root
      when 'serum'
        case cmd.switch
        when "get"
          return SerumGetCommand
        when "use"
          return SerumUseCommand
        when "give"
          return SerumGiveCommand
        when nil
          return SerumCommand
        end


      end
      nil
    end

    def self.get_event_handler(event_name)
      nil
    end

    def self.get_web_request_handler(request)
      nil
    end

  end
end
