module AresMUSH
  module TDSCombat
    class MountsListCmd
      include CommandHandler
      
      def check_mounts_allowed
        return t('tdscombat.mounts_disabled') if !TDSCombat.mounts_allowed?
        return nil
      end
      
      def handle
        template = GearListTemplate.new TDSCombat.mounts, t('tdscombat.mounts_title')
        client.emit template.render
      end
    end
  end
end