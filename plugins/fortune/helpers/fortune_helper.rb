module AresMUSH
  module Fortune

    def self.get_fortune()
      fortune_list = Global.read_config('fortune','fortune_list')
      max_fortunes = fortune_list.count
      fortune_to_tell = fortune_list[rand(max_fortunes)]
      return fortune_to_tell
    end

    def self.get_book()
      book_list = Global.read_config('fortune','book_list')
      max_books = book_list.count
      book_to_get = book_list[rand(max_books)]
      return book_to_get
    end

    def self.get_fish(char, room)
      fish_biome = `"biome"=>"`+room.fish_biome+`"`
      rarity = `"rarity"=>"`+[1, 1, 1, 1, 2, 2, 2, 3, 3][rand(9)].to_s+`"`
      fish_list = Global.read_config('fortune','fish_list').select { |name, details| details.to_s.include?(fish_biome) }
      filter_fish_list = fish_list.select { |name, details| details.to_s.include?(rarity) }
      max_fish = filter_fish_list.count
      fish_to_catch = filter_fish_list.to_a[rand(max_fish-1)]
      fish_to_catch_name = fish_to_catch[0]
      fish_size_count = fish_to_catch[1].to_a[1][1].count
      fish_size = fish_to_catch[1].to_a[1][1][rand(fish_size_count-1)]
      case fish_size
      when "tiny"
        case rarity 
        when 1
          roll_mod = 2
        when 2
          roll_mod = 1
        when 3
          roll_mod = 0
        end
      when "small"
        case rarity 
        when 1
          roll_mod = 2
        when 2
          roll_mod = 1
        when 3
          roll_mod = 0
        end
      when "medium"
        case rarity 
        when 1
          roll_mod = 1
        when 2
          roll_mod = 0
        when 3
          roll_mod = -1
        end
      when "large"
        case rarity 
        when 1
          roll_mod = 0
        when 2
          roll_mod = -1
        when 3
          roll_mod = -2
        end
      when "gigantic"
        case rarity 
        when 1
          roll_mod = -2
        when 2
          roll_mod = -3
        when 3
          roll_mod = -4
        end
      end
      roll = char.roll_ability("Athletics",roll_mod).to_a[0][1]
      if roll > 0 
        message = t('fortune.caught_fish', :name => char.name, :fish_caught => fish_to_catch_name, :fish_size => fish_size)
        return message
      else 
        message = t('fortune.fish_got_away', :name => char.name, :fish_caught => fish_to_catch_name, :fish_size => fish_size)
        return message
      end
    end

    def self.handle_fortune_given_achievement(char)
      Achievements.achievement_levels("fortune_count").reverse.each do |count|
        if (char.fortunes_told_alltime == count)
          Achievements.award_achievement(char, "fortune_count", char.fortunes_told_alltime)
          break
        end
      end
    end

    def self.handle_book_given_achievement(char)
      Achievements.achievement_levels("book_count").reverse.each do |count|
        if (char.books_got_alltime == count)
          Achievements.award_achievement(char, "book_count", char.books_got_alltime)
          break
        end
      end
    end

  end
end