module AresMUSH
  module Fortune

    def self.get_fortune()
      fortune_list = Global.read_config('fortune','fortune_list')
      max_fortunes = fortune_list.count
      fortune_to_tell = fortune_list[rand(max_fortunes)]
      return fortune_to_tell
    end

    def self.handle_fortune_given_achievement(char)
      Achievements.achievement_levels("fortune_count").reverse.each do |count|
        Global.logger.debug "count: #{count}, char.fortunes_told_alltime: #{char.fortunes_told_alltime}"
        if (char.fortunes_told_alltime == count)
          Achievements.award_achievement(char, "fortune_count", char.fortunes_told_alltime)
        end
      end
    end

  end
end