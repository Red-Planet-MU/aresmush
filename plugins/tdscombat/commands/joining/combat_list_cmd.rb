module AresMUSH
  module TDSCombat
    class CombatListCmd
      include CommandHandler
      
      def handle
        list = TDSCombat.combats.map { |c| format_combat(c)}
        template = BorderedListTemplate.new list, t('tdscombat.active_combats'), nil, t('tdscombat.active_combats_titlebar')
        client.emit template.render
        
        
      end
      
      def format_combat(combat)
        combatants = combat.combatants.map { |c| c.name }.join(" ")
        num = combat.id.to_s
        scene_id = combat.scene ? combat.scene.id : ""
        "#{num.ljust(3)} #{scene_id.ljust(5)} #{combat.organizer.name.ljust(15)} #{combatants}"
      end
    end
  end
end