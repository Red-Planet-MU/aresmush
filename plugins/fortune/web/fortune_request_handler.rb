module AresMUSH
  module Fortune
    class GetFortuneRequestHandler
      def handle(request)

        char_name_or_id = request.args['char_id']
        enactor = request.enactor
        error = Website.check_login(request)
        scene_id = request.args['id']
        scene = Scene[request.args['id']]

        Global.logger.debug "scene: #{scene}, id: #{scene_id}, enactor: #{enactor}"
          
        return error if error
        if enactor.fortunes_told_lately >= 3
          return { error: t('fortune.cooldown_on')  }
        end
        fortune_to_tell = Fortune.get_fortune()

        Global.logger.debug "fortune_to_tell: #{fortune_to_tell}"
        enactor.update(fortunes_told_lately: enactor.fortunes_told_lately + 1)
        enactor.update(fortunes_told_alltime: enactor.fortunes_told_alltime + 1)
        scene_message = t('fortune.told_fortune', :name => enactor.name, :fortune_told => fortune_to_tell)
        Global.logger.debug "scene_message: #{scene_message}"
        Fortune.handle_fortune_given_achievement(enactor)
        Global.logger.debug "Not broken yet"
        Scenes.add_to_scene(scene, scene_message)
        Global.logger.debug "Not broken yet 2"
        if enactor.room.scene
          enactor.room.emit scene_message
          Global.logger.debug "Not broken yet 3"
        end
        
      end
    end
  end
end