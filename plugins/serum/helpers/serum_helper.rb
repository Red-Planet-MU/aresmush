module AresMUSH
  module Serum

    def self.find_serums_type(serum)
      case serum
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

    def self.find_serums_has(char, serum_type)
      case serum_type
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

    def self.modify_serum(char, serum_type, amount)
      serum = Serum.find_serums_has(char, serum_type) + amount
      update_serum_type = char.find_serums_type(serum_type)
      case update_serum_type
      when "v_serum_has"
        char.update(v_serum_has: serum)
      when "Quickhand"
        char.update(qh_serums_has: serum)
      when "Glass Cannon"
        char.update(gc_serums_has: serum)
      when "Hardy"
        char.update(h_serums_has: serum)
      when "Adreno"
        char.update(a_serums_has: serum)
      end
    end

    def self.end_at(duration)
      Time.now + duration.hour
    end

    def self.expire(char)
      char.update(looking_for_rp: false)
    end

    def self.chars_looking_for_rp
      Chargen.approved_chars.select { |c| c.looking_for_rp == true }
    end

    def self.type_marker(char)
      case char.looking_for_rp_type
      when "scene"
        return ""
      when "text"
        return "#"
      end
    end

    def self.web_list
      chars_looking_for_rp.map { |c| { name: c.name, type_maker: type_marker(c) } }
    end

    def self.char_names
      chars_looking_for_rp.map { |c| c.name }
    end

    def self.announce_toggle_on(char)
      char.update(looking_for_rp_announce: "on")
    end

    def self.announce_toggle_off(char)
      char.update(looking_for_rp_announce: "off")
    end

  end
end