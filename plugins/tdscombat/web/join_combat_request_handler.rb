module AresMUSH
  module TDSCombat
    class JoinCombatRequestHandler
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
                
        if (combat.turn_in_progress)
          return { error: t('tdscombat.turn_in_progress') }
        end

        combatant = TDSCombat.join_combat(combat, sender.name, TDSCombat.default_combatant_type, sender, nil)                    
        if (!combatant)
          return { error: t('tdscombat.unable_to_join_combat') }
        end
        
        TDSCombat.build_combat_web_data(combat, enactor)
        
      end
    end
  end
end


