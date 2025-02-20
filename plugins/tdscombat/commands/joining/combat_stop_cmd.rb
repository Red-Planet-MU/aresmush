module AresMUSH
  module TDSCombat
    class CombatStopCmd
      include CommandHandler
      include NotAllowedWhileTurnInProgress
      
      attr_accessor :num
      
      def parse_args
        self.num = trim_arg(cmd.args)
      end
      
      def handle
        combat = TDSCombat.find_combat_by_number(client, self.num)
        return if (!combat)

        TDSCombat.emit_to_combat combat, t('tdscombat.combat_stopped_by', :name => enactor_name)
        client.emit_success t('tdscombat.stopping_combat', :num => self.num)
        
        combat.delete
        client.emit_success t('tdscombat.combat_stopped', :num => self.num)
      end
    end
  end
end