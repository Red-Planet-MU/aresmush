module AresMUSH
  module TDSCombat
    class CombatHeroCmd
      include CommandHandler
      include NotAllowedWhileTurnInProgress
      
      
      def check_points
        return t('tdscombat.no_luck') if enactor.luck < 1
        return nil
      end
    
      
      def handle
        TDSCombat.with_a_combatant(enactor_name, client, enactor) do |combat, combatant|
          if (!combatant.is_ko)
            client.emit_failure t('tdscombat.not_koed')
            return
          end
          
          enactor.spend_luck(1)
          Achievements.award_achievement(enactor, "fs3_hero")
          
          combatant.update(is_ko: false)
          wound = TDSCombat.worst_treatable_wound(enactor)
          if (wound)
            TDSCombat.heal(wound, 1)
          end
          
          TDSCombat.emit_to_combat combat, t('tdscombat.back_in_the_fight', :name => enactor_name), nil, true
        end
      end
    end
  end
end