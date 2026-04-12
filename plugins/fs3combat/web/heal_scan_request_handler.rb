module AresMUSH
  module FS3Combat
    class HealScanRequestHandler
      def handle(request)
        id = request.args['id']
        enactor = request.enactor

        
        error = Website.check_login(request)
        return error if error
        
        damage = {}
        Character.all.each do |c|
          damage_mod = FS3Combat.total_damage_mod(c)
          if (damage_mod != 0)
            damage[c.name] = damage_mod
          end
        end

        damaged_chars = Chargen.approved_chars.select { |c| FS3Combat.total_damage_mod(c) < 0}


        heal_scan_chars = damaged_chars.sort_by { |pc| FS3Combat.total_damage_mod(pc)}.map { |c| { name: c.name, icon: Website.icon_for_char(c), damage_mod: FS3Combat.total_damage_mod(c) } }
        
        {heal_scan_list: heal_scan_chars}
      end
    end
  end
end


