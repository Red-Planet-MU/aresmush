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