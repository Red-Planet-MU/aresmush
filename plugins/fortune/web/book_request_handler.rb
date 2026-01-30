module AresMUSH
  module Fortune
    class GetBookRequestHandler
      def handle(request)

        char_name_or_id = request.args['char_id']
        enactor = request.enactor
        error = Website.check_login(request)
        scene_id = request.args['id']
        scene = Scene[request.args['id']]
          
        return error if error
        if enactor.books_got_lately >= 3
          return { error: t('fortune.cooldown_on')  }
        end
        book_to_Get = Fortune.get_book()

        enactor.update(books_got_lately: enactor.books_got_lately + 1)
        enactor.update(books_got_alltime: enactor.books_got_alltime + 1)
        scene_message = t('fortune.got_book', :name => enactor.name, :book_got => fortune_to_tell)
        Fortune.handle_book_given_achievement(enactor)
        Scenes.add_to_scene(scene, scene_message)
        if enactor.room.scene
          enactor.room.emit scene_message
        end
        Global.logger.debug "For some reason the fortune code requires me to be here"
      end
    end
  end
end