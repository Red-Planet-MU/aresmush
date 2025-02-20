module AresMUSH
  module TDSCombat
    class CombatHeroRequestHandler
      def handle(request)
        combat_id = request.args[:combat_id]
        sender_name = request.args[:sender]
        command_text = request.args[:command]
        enactor = request.enactor
                
        error = Website.check_login(request)
        return error if error
        
        sender = sender_name.blank? ? enactor : Character.named(sender_name)
        combat = Combat[combat_id]
        if (!combat || !sender)
          return { error: t('webportal.not_found') }
        end
        
        if (!AresCentral.is_alt?(sender, enactor))
          return { error: t('dispatcher.not_allowed') }
        end
        
        if (sender.combat != combat)
           return { error: t('tdscombat.you_are_not_in_combat') }
        end
         
        combatant = sender.combatant
        if (!combatant.is_ko)
          return { error: t('tdscombat.not_koed') }
        end

        if (sender.luck < 1) 
          return { error: t('tdscombat.no_luck') }
        end
        
        sender.spend_luck(1)
        Achievements.award_achievement(sender, "fs3_hero")
        
        combatant.update(is_ko: false)
        wound = TDSCombat.worst_treatable_wound(sender)
        if (wound)
          TDSCombat.heal(wound, 1)
        end
        
        TDSCombat.emit_to_combat combat, t('tdscombat.back_in_the_fight', :name => sender.name), nil, true
            

       TDSCombat.build_combat_web_data(combat, enactor)
      end
    end
  end
end


