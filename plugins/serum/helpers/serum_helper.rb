module AresMUSH
    module Serum
  
      def self.find_serums_type(serum_name)
        case serum_name
        when "Revitalizer"
          "v_serums_has"
        when "Quickhand"
          "qh_serums_has"
        when "Glass Cannon"
          "gc_serums_has"
        when "Hardy"
          "h_serums_has"
        when "Adreno"
          "a_serums_has"
        end
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
        case heal_success_level
        when -1
          heal_amount = 0
          dice_message = t('tdd.botch')
          FS3Combat.inflict_damage(target, "FLESH", "Botched Serum")
          return t('serum.c_used_v_made_it_worse', :name => char.name, :target => target.name, :serum_name => serum_name, :dice_result => dice_message)
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
          return t('serum.used_v_in_combat', :name => char.name, :target => target.name, :serum_name => serum_name, :heal_points => heal_amount, :dice_result => dice_message)
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
  
    end
  end