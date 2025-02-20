module AresMUSH
  module TDSCombat
    class CombatSceneCmd
      include CommandHandler

      attr_accessor :scene_id
      
      def parse_args
        self.scene_id = integer_arg(cmd.args)  
      end
      
      def handle
        if (!enactor.is_in_combat?)
          client.emit_failure t('tdscombat.you_are_not_in_combat')
          return
        end
              
        combat = enactor.combat
        scene = Scene[self.scene_id]
        
        if (!scene)
          client.emit_failure t('tdscombat.invalid_scene')
          return
        end
        
        if (!Scenes.can_read_scene?(enactor, scene))
          client.emit_failure t('tdscombat.cant_link_scene')
          return
        end
        
        combat.update(scene: scene)
        Scenes.combat_started(scene, combat)
        client.emit_success t('tdscombat.scene_set', :scene => scene.id)
        
      end
    end
  end
end