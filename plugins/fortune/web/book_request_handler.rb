module AresMUSH
  module Fortune
    class GetBookRequestHandler
      def handle(request)

        char_name_or_id = request.args['char_id']
        char = Character.find_one_by_name(char_id)
        enactor = request.enactor
        error = Website.check_login(request)
        scene_id = request.args['id']
        scene = Scene[request.args['id']]
          
        return error if error
        if enactor.books_got_lately >= 3
          return { error: t('fortune.cooldown_on')  }
        end
        book_to_get = Fortune.get_book()

        char.update(books_got_lately: char.books_got_lately + 1)
        char.update(books_got_alltime: char.books_got_alltime + 1)
        scene_message = t('fortune.got_book', :name => enactor.name, :book_got => book_to_get)
        Fortune.handle_book_given_achievement(char)
        Scenes.add_to_scene(scene, scene_message)
        if enactor.room.scene
          enactor.room.emit scene_message
        end
        Global.logger.debug "For some reason the fortune code requires me to be here"
      end
    end
  end
end