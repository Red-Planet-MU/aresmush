module AresMUSH
  module TDSCombat
    class CombatHitlocsCmd
      include CommandHandler
      
      attr_accessor :name
      
      def parse_args
        self.name = cmd.args ? titlecase_arg(cmd.args) : enactor.name
      end

      def check_in_combat
        return t('tdscombat.you_are_not_in_combat') if !enactor.is_in_combat?
        return nil
      end
      
      def handle
        
        combat = enactor.combat
        vehicle = combat.find_vehicle_by_name(self.name)
        if (vehicle)
          client.emit_failure t('tdscombat.use_pilot_name_for_vehicle_hitlocs')
          return
        end
        
        TDSCombat.with_a_combatant(self.name, client, enactor) do |combat, combatant|
          hitlocs = TDSCombat.hitloc_areas(combatant).keys
          
          footer = combatant.is_in_vehicle? ? "%R%xh#{t('tdscombat.hitlocs_vehicle_warning', :name => self.name)}%xn" : nil
          template = BorderedListTemplate.new hitlocs.sort, t('tdscombat.hitlocs_for', :name => self.name), footer
          client.emit template.render
        end
      end
    end
  end
end