module AresMUSH
  module TDSCombat
    
    module NotAllowedWhileTurnInProgress
      def check_turn_in_progress
        combat = enactor.combat
        return nil if !combat
        return t('tdscombat.turn_in_progress') if combat.turn_in_progress
        return nil
      end
    end
  end
end