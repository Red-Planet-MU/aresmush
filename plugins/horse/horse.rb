$:.unshift File.dirname(__FILE__)

module AresMUSH
  module Horse
    def self.plugin_dir
      File.dirname(__FILE__)
    end

    def self.shortcuts
      Global.read_config("horse", "shortcuts")
    end

    def self.get_cmd_handler(client, cmd, enactor)
      case cmd.root
      when 'horse'
        case cmd.switch
        when "get"
          return HorseGetCommand
        when "confirm"
          return HorseGetConfirmCommand
        when "desc"
          return HorseDescCommand
        when "give"
          return SerumGiveCommand
        when nil
          return HorseCommand
        end


      end
      nil
    end

    def self.get_event_handler(event_name)
      nil
    end

    def self.get_web_request_handler(request)
      case request.cmd
      when "getHorse"
        return GetHorseRequestHandler
      when "updateHorse"
        return UpdateHorseRequestHandler
      end
      nil
    end

  end
end