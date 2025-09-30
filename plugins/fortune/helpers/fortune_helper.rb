module AresMUSH
  module Fortune

    def self.get_fortune()
      fortune_list = Global.read_config('fortune','fortune_list')
      Global.logger.debug "#{fortune_list}"
    end


  end
end