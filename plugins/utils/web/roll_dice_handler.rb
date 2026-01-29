module AresMUSH
  module Utils
    class RollDiceRequestHandler
      def handle(request)
        scene = Scene[request.args['id']]
        enactor = request.enactor
        dice = request.args['dice']
        faces = request.args['faces']
        private_dice = request.args['private_dice']
        
        if (!scene)
          return { error: t('webportal.not_found') }
        end
        
        error = Website.check_login(request)
        return error if error

        if (!Scenes.can_read_scene?(enactor, scene))
          return { error: t('scenes.access_not_allowed') }
        end
        
        if (scene.completed)
          return { error: t('scenes.scene_already_completed') }
        end
        
        if (!scene.room)
          raise "Trying to emit to a scene that doesn't have a room."
        end

        Global.logger.debug "#{enactor.name} rolling #{dice}d#{faces} in scene #{scene.id}."
        num = (dice|| "0").to_i
        sides =(faces || "0").to_i

        message = Utils.roll_dice(enactor.name, num, sides)
        
        if (!message)
          return { error: t('dice.invalid_dice_string') }
        end
        if !private_dice
          scene.room.emit_ooc message
          Scenes.add_to_scene(scene, message, Game.master.system_character, false, true)
          {}
        else
          return { private_dice_result: message}
        end
      end
    end
  end
end