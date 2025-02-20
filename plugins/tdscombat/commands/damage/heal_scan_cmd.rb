module AresMUSH
  module TDSCombat
    class HealScanCmd
      include CommandHandler
      
      def handle
        damage = {}
        Character.all.each do |c|
          damage_mod = TDSCombat.total_damage_mod(c)
          if (damage_mod != 0)
            damage[c.name] = damage_mod
          end
        end
        
        list = damage.sort_by { |k, v| v }.map { |name, damage_mod| "#{name.ljust(30)} #{damage_mod}" }
        
        template = BorderedListTemplate.new list, t('tdscombat.damage_scan_title'), nil, t('tdscombat.damage_scan_subtitle')
        client.emit template.render
      end
      

      
    end
  end
end