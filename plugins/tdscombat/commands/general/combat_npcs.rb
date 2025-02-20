module AresMUSH
  module TDSCombat
    class CombatNpcsCmd
      include CommandHandler
      
      def handle
        types = Global.read_config("tdscombat", "npc_types")
        text = ""
        
        types.each do |name, values|
          text << "\n%xh#{name}%xn\n"
          values.each do |skill, rating|
            text << "     #{skill}: #{rating}"
          end
        end
        
        template = BorderedDisplayTemplate.new text, t('tdscombat.npcs_title')
        client.emit template.render        
      end
    end
  end
end