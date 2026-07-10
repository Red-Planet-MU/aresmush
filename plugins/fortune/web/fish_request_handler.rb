module AresMUSH
  module Fortune
    class CatchFishRequestHandler
      def handle(request)

        char_id = request.args['char_id']
        char = Character.find_one_by_name(char_id)
        enactor = request.enactor
        error = Website.check_login(request)
        scene_id = request.args['id']
        scene = Scene[request.args['id']]
          
        return error if error
        if char.fish_caught_lately >= 3
          return { error: t('fortune.cooldown_on')  }
        end
        message = Fortune.get_fish(char, scene.room)
        if message.include? "reels"
          char.update(fish_caught_lately: enactor.fish_caught_lately + 1)
          char.update(fish_caught_alltime: enactor.fish_caught_alltime + 1)
          #Fortune.handle_fish_caught_achievement(enactor)
        end
        scene_message = message
        Scenes.add_to_scene(scene, scene_message)
        scene.room.emit scene_message
        Global.logger.debug "For some reason the fortune code requires me to be here"
      end
    end
  end
end