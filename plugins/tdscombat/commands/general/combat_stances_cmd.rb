module AresMUSH
  module TDSCombat
    class CombatStancesCmd
      include CommandHandler

      def handle
        template = StancesTemplate.new(TDSCombat.stances)
        client.emit template.render
      end
    end
  end
end