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
        
        list = damage.sort_by { |k, v| v }.map { |name, damage_mod| "#{name.ljust(30)} #{damage_mod}" }
        
        template = BorderedListTemplate.new list, t('fs3combat.damage_scan_title'), nil, t('fs3combat.damage_scan_subtitle')
        client.emit template.render
        
        FS3Combat.build_combat_web_data(combat, enactor)
      end
    end
  end
end


