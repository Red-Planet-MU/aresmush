module AresMUSH
  module Profile
    class CustomCharFields
      
      # Gets custom fields for display in a character profile.
      #
      # @param [Character] char - The character being requested.
      # @param [Character] viewer - The character viewing the profile. May be nil if someone is viewing
      #    the profile without being logged in.
      #
      # @return [Hash] - A hash containing custom fields and values. 
      #    Ansi or markdown text strings must be formatted for display.
      # @example
      #    return { goals: Website.format_markdown_for_html(char.goals) }
      def self.get_fields_for_viewing(char, viewer)
        return {
          comps: Compliments.get_comps(char),
          v_serums: char.v_serums_has,
          a_serums: char.a_serums_has,
          h_serums: char.h_serums_has,
          qh_serums: char.qh_serums_has,
          gc_serums: char.gc_serums_has,
          horse_name: char.demographic("horse name"),
          horse_color: char.horse_color,
          horse_temperament: char.horse_temperament,
          horse_desc: char.horse_desc,
          song_link: char.demographic("theme song link"),
          approved_chars: Character.all.select { |c| c.is_approved? },
          viewer: if viewer
                    viewer.name
                  else 
                    nil
                  end,
          pals: Socializer.list_pals(char),
          
        }
      end
    
      # Gets custom fields for the character profile editor.
      #
      # @param [Character] char - The character being requested.
      # @param [Character] viewer - The character editing the profile.
      #
      # @return [Hash] - A hash containing custom fields and values. 
      #    Multi-line text strings must be formatted for editing.
      # @example
      #    return { goals: Website.format_input_for_html(char.goals) }
      def self.get_fields_for_editing(char, viewer)
        return {
          txt_color: char.txt_color,
        }
      end

      # Gets custom fields for character creation (chargen).
      #
      # @param [Character] char - The character being requested.
      #
      # @return [Hash] - A hash containing custom fields and values. 
      #    Multi-line text strings must be formatted for editing.
      # @example
      #    return { goals: Website.format_input_for_html(char.goals) }
      def self.get_fields_for_chargen(char)
        return {}
      end
      
      # Deprecated - use save_fields_from_profile_edit2 instead
      def self.save_fields_from_profile_edit(char, char_data)
        return []
      end
      
      # Saves fields from character creation (chargen).
      #
      # @param [Character] char - The character being updated.
      # @param [Hash] chargen_data - A hash of character fields and values. Your custom fields
      #    will be in chargen_data['custom']. Multi-line text strings should be formatted for MUSH.
      #
      # @return [Array] - A list of error messages. Return an empty array ([]) if there are no errors.
      # @example
      #        char.update(goals: Website.format_input_for_mush(chargen_data['custom']['goals']))
      #        return []
      def self.save_fields_from_chargen(char, chargen_data)
        return []
      end
      
      # Saves fields from profile editing.
      #
      # @param [Character] char - The character being updated.
      # @param [Character] enactor - The character triggering the update.
      # @param [Hash] char_data - A hash of character fields and values. Your custom fields
      #    will be in char_data['custom']. Multi-line text strings should be formatted for MUSH.
      #
      # @return [Array] - A list of error messages. Return an empty array ([]) if there are no errors.
      # @example
      #        char.update(goals: Website.format_input_for_mush(char_data['custom']['goals']))
      #        return []
      def self.save_fields_from_profile_edit2(char, enactor, char_data)
        # By default, this calls the old method for backwards compatibility. The old one didn't
        # use enactor. Replace this with your own code.
        Global.logger.debug "#{char_data}"
        char.update(txt_color: Website.format_input_for_mush(char_data[:custom][:txt_color]))
      end

      
    end
  end
end