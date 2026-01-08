module AresMUSH
  module Fortune
    class GetFortuneRequestHandler
      def handle(request)

        char_name_or_id = request.args['char_id']
        char = Character.find_one_by_name(char_name_or_id)
        enactor = request.enactor
        error = Website.check_login(request)
          
        return error if error
        if enactor.fortunes_told_lately >= 3
          return { error: t('fortune.cooldown_on')  }
        end
        fortune_to_tell = Fortune.get_fortune()
        enactor.update(fortunes_told_lately: enactor.fortunes_told_lately + 1)
        enactor.update(fortunes_told_alltime: enactor.fortunes_told_alltime + 1)
        message = t('fortune.told_fortune', :name => enactor.name, :fortune_told => fortune_to_tell)
        Fortune.handle_fortune_given_achievement(enactor)
        enactor.room.emit message
        if enactor.room.scene
          Scenes.add_to_scene(enactor.room.scene, message)
        end

      end
    end
  end
end