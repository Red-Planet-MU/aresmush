module AresMUSH
    module Serum
  
      def self.find_serums_type(serum_name)
        case serum_name
        when "Vitalizer"
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
        when "Vitalizer"
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
  
      def self.healing_serum(char, target)
        heal_roll = TDD.parse_and_roll(enactor, "Medicine")
        heal_success_level = TDD.get_success_level(heal_roll)
        dice_message = TDD.print_dice(heal_roll)
        wound = FS3Combat.worst_treatable_wound(self.target)
        case heal_success_level
        when -1
          heal_amount = 0
          dice_message = t('tdd.botch')
          FS3Combat.inflict_damage(self.target, "FLESH", "Botched Serum")
          return t('serum.c_used_v_made_it_worse', :name => enactor.name, :target => self.target.name, :serum_name => self.serum_name, :dice_result => dice_message)
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
          return t('serum.used_v_in_combat', :name => enactor.name, :target => self.target.name, :serum_name => self.serum_name, :heal_points => heal_amount, :dice_result => dice_message)
        end
      end
  
    end
  end