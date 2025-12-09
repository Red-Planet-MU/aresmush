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
        char.update_demographic :horsename, horse_name
      end
  
      def self.find_serums_has(char, serum_name)
        case serum_name
        when "Revitalizer"
          char.v_serums_has
        when "Quickhand"
          char.qh_serums_has
        when "Glass Cannon"
          char.gc_serums_has
        when "Hardy"
          char.h_serums_has
        when "Adreno"
          char.a_serums_has
        end
      end
  
      def self.modify_serum(char, serum_name, amount)
        serum = Serum.find_serums_has(char, serum_name) + amount
        update_serum_type = Serum.find_serums_type(serum_name)
  
        case update_serum_type
        when "v_serums_has"
          char.update(v_serums_has: serum)
        when "qh_serums_has"
          char.update(qh_serums_has: serum)
        when "gc_serums_has"
          char.update(gc_serums_has: serum)
        when "h_serums_has"
          char.update(h_serums_has: serum)
        when "a_serums_has"
          char.update(a_serums_has: serum)
        end
      end
  
      def self.combat_healing_serum(char, target, serum_name)
        heal_roll = TDD.parse_and_roll(char, "Medicine")
        heal_success_level = TDD.get_success_level(heal_roll)
        dice_message = TDD.print_dice(heal_roll)
        wound = FS3Combat.worst_treatable_wound(target)
        display_name = Global.read_config('serum',serum_name,'display_name')
        case heal_success_level
        when -1
          heal_amount = 0
          dice_message = t('tdd.botch')
          FS3Combat.inflict_damage(target, "FLESH", "Botched Serum")
          return t('serum.c_used_v_made_it_worse', :name => char.name, :target => target.name, :serum_name => display_name, :dice_result => dice_message)
        when 0
          heal_amount = 1
        when 1..2
          heal_amount = 3
        when 3..4
          heal_amount = 5
        when 5..7
          heal_amount = 7
        when 16..99
          heal_amount = 9
          dice_message = t('tdd.critical_success')
        end

        if heal_success_level >= 0
          FS3Combat.heal(wound, heal_amount)
          return t('serum.used_v_in_combat', :name => char.name, :target => target.name, :serum_name => display_name, :heal_points => heal_amount, :dice_result => dice_message)
        end
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