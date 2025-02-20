module AresMUSH
  module TDSCombat
    def self.is_enabled?
      !Global.plugin_manager.is_disabled?("tdscombat")
    end    
  end
end
