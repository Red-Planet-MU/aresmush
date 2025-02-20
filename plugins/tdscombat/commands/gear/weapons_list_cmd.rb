module AresMUSH
  module TDSCombat
    class WeaponsListCmd
      include CommandHandler
      include TemplateFormatters      
      
      def handle
        template = GearListTemplate.new TDSCombat.weapons, t('tdscombat.weapons_title')
        client.emit template.render
      end
    end
  end
end