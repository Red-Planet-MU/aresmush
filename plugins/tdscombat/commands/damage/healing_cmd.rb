module AresMUSH
  module TDSCombat
    class HealingCmd
      include CommandHandler
      
      def handle
        template = HealingTemplate.new(enactor)
        client.emit template.render
      end
    end
  end
end