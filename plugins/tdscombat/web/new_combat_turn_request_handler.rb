module AresMUSH
  module TDSCombat
    class NewCombatTurnRequestHandler
      def handle(request)
        combat_id = request.args[:combat_id]
        sender_name = request.args[:sender]
        enactor = request.enactor
        
        error = Website.check_login(request)
        return error if error
        
        sender = sender_name.blank? ? enactor : Character.named(sender_name)
        combat = Combat[combat_id]
        if (!combat || !sender)
          return { error: t('tdscombat.invalid_combat_number') }
        end
        
        if (!AresCentral.is_alt?(sender, enactor))
          return { error: t('dispatcher.not_allowed') }
        end
        
        if (sender.combat != combat)
           return { error: t('tdscombat.you_are_not_in_combat') }
        end
        
        if (!TDSCombat.can_manage_combat_from_web?(sender, combat))
          return { error: t('dispatcher.not_allowed') }
        end        

        if (combat.turn_in_progress)
          return { error: t('tdscombat.turn_in_progress') }
        end

        TDSCombat.new_turn(sender, combat)
                    
        {
        }
      end
    end
  end
end


