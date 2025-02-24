$:.unshift File.dirname(__FILE__)

module AresMUSH
  module TDD
    def self.plugin_dir
      File.dirname(__FILE__)
    end
 
    def self.shortcuts
      Global.read_config("tdd", "shortcuts")
    end

    def self.achievements
      Global.read_config('tdd', 'achievements')
    end
 
    def self.get_cmd_handler(client, cmd, enactor)
      Global.logger.debug "cmd.root: #{cmd.root}"
      case cmd.root
      when "tddroll"
        if (cmd.args =~ / vs /)
          return TDDOpposedRollCmd
        else
          return TDDRollCmd
        end
      end
      nil
    end
    
    def self.get_web_request_handler(request)
      case request.cmd
      when "abilities"
        return AbilitiesRequestHandler
      when "addJobRoll"
        return AddJobRollRequestHandler
      when "addSceneRoll"
        return AddSceneRollRequestHandler
      end
      nil
    end
    
  end
end
