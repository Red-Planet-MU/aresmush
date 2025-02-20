module AresMUSH
  module TDSCombat
    class StartCombatRequestHandler
      def handle(request)
        scene_id = request.args[:scene_id]
        enactor = request.enactor
        
        error = Website.check_login(request)
        return error if error
        
        request.log_request
        
        if (!scene_id.blank?)
          scene = Scene[scene_id]
          if (!scene)
            return { error: t('webportal.not_found') }
          end
          
          combat = TDSCombat.combat_for_scene(scene)
        
          if (combat)
            return { error: t('tdscombat.already_combat_for_scene')}
          end
        else 
          scene = nil
        end
        
        
        if (enactor.is_in_combat?) 
          return { error: t('tdscombat.you_are_already_in_combat') }
        end
        
        combat = Combat.create(:organizer => enactor, :is_real => true, scene: scene)
        TDSCombat.join_combat(combat, enactor.name, "Observer", enactor, nil)
        
        TDSCombat.emit_to_combat(combat, t('tdscombat.combat_scene_started', :name => enactor.name))
                
        TDSCombat.build_combat_web_data(combat, enactor)
      end
    end
  end
end


