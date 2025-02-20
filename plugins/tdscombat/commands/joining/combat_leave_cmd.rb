module AresMUSH
  module TDSCombat
    class CombatLeaveCmd
      include CommandHandler
      include NotAllowedWhileTurnInProgress
      
      attr_accessor :names    
      
      def parse_args
        self.names = cmd.args ? list_arg(cmd.args) : [enactor.name]
      end

      def handle
        self.names.each do |name|
          TDSCombat.with_a_combatant(name, client, enactor) do |combat, combatant|
            TDSCombat.leave_combat(combat, combatant)
          end
        end
      end
    end
  end
end