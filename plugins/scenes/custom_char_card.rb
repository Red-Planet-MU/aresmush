module AresMUSH
  module Scenes
    
    def self.custom_char_card_fields(char, viewer)
      
      # Return nil if you don't need any custom fields.
     return {
          
          song_link: char.demographic("theme song link"),
          
        }
    end
  end
end
