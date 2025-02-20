module AresMUSH
  module TDSCombat
    class ArmorListCmd
      include CommandHandler
      
      def handle
        template = GearListTemplate.new TDSCombat.armors, t('tdscombat.armor_title')
        client.emit template.render
      end
      
    end
  end
end