module AresMUSH
  module Horse

    def print_rating
      case rating
      when 0
        return ""
      when 1
        return "%xg@%xn"
      when 2
        return "%xg@@%xn"
      when 3
        return "%xg@@%xy@%xn"
      when 4
        return "%xg@@%xy@@%xn"
      when 5
        return "%xg@@%xy@@%xr@%xn"
      when 6
        return "%xg@@%xy@@%xr@@%xn"
      when 7
        return "%xg@@%xy@@%xr@@%xb@%xn"
      when 8
        return "%xg@@%xy@@%xr@@%xb@@%xn"
      end
    end
    
    def rating_name
      case rating
      when 0
        return t('fs3skills.incapable_rating')
      when 1
        return t('fs3skills.everyman_rating')
      when 2
        return t('fs3skills.fair_rating')
      when 3
        return t('fs3skills.competent_rating')
      when 4
        return t('fs3skills.good_rating')
      when 5
        return t('fs3skills.great_rating')
      when 6
        return t('fs3skills.exceptional_rating')
      when 7
        return t('fs3skills.amazing_rating')
      when 8
        return t('fs3skills.legendary_rating')
      end
    end

      def format_bond(char)
        #linebreak = i % 2 == 1 ? "" : "%r"
        
        #if (self.screen_reader_on)
        #  return "#{linebreak}#{b.name}: #{b.rating} #{b.rating_name} :: "
        #end
        b = char.horse_bond  
        name = "%xh#{b.name}:%xn"
        rating_text = "#{b.rating_name}#{linked_attr}"
        rating_dots = b.print_rating
        "#{left(rating_dots, 8)}"
        #"#{linebreak}#{left(name, 14)} #{left(rating_dots, 8)} #{left(rating_text, 16)}"
      end
  
      def self.generate_horse(char)
        horse_name = Global.read_config('horse','horse_names')[rand(0...Global.read_config('horse','horse_names').count)]
        horse_color = Global.read_config('horse','horse_colors')[rand(0...Global.read_config('horse','horse_colors').count)]
        horse_temperament = Global.read_config('horse','horse_temperaments')[rand(0...Global.read_config('horse','horse_temperaments').count)]
        char.update(horse_color: horse_color)
        char.update(horse_temperament: horse_temperament)
        char.update_demographic "horse name", horse_name
      end

      def self.fetch_serum(char, viewer)
        return {serums: Website.format_markdown_for_html(char.v_serums_has)#, 
        #a_serums: Website.format_markdown_for_html(char.a_serums_has), 
        #qh_serums: Website.format_markdown_for_html(char.qh_serums_has), 
        #h_serums: Website.format_markdown_for_html(char.h_serums_has), 
        #gc_serums: Website.format_markdown_for_html(char.gc_serums_has)
      }
      end

      def self.get_serum(char, viewer)
        return {serums: Website.format_markdown_for_html(char.v_serums_has)#, 
        #a_serums: Website.format_markdown_for_html(char.a_serums_has), 
        #qh_serums: Website.format_markdown_for_html(char.qh_serums_has), 
        #h_serums: Website.format_markdown_for_html(char.h_serums_has), 
        #gc_serums: Website.format_markdown_for_html(char.gc_serums_has)
      }
      end
  
    end
  end