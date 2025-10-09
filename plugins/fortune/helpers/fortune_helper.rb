module AresMUSH
  module Fortune

    def self.get_fortune()
      fortune_list = Global.read_config('fortune','fortune_list')
      Global.logger.debug "#{fortune_list}"
      max_fortunes = fortune_list.count
      fortune_to_tell = fortune_list[rand(max_fortunes)]
      Global.logger.debug "#{fortune_to_tell}"
      return fortune_to_tell
    end

    def self.expire(char)
      char.update(fortune_cooldown_expires_at: nil)
    end

  end
end