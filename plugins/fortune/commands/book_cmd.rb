module AresMUSH
  module Fortune
    class BookCommand
      include CommandHandler

      attr_accessor :duration

      def parse_args
        #self.fortune = titlecase_arg(cmd.args)

      end

      def check_errors
        return t('fortune.no_book_machine') if enactor.room.can_use_book != true
        return t('fortune.cooldown_on') if enactor.books_got_lately >= 3
      end

      def handle
        book_to_get = Fortune.get_book()
        enactor.update(books_got_lately: enactor.books_got_lately + 1)
        enactor.update(books_got_alltime: enactor.books_got_alltime + 1)
        message = t('fortune.got_book', :name => enactor.name, :book_got => book_to_get)
        enactor.room.emit message
        Fortune.handle_book_given_achievement(enactor)
        if enactor.room.scene
          Scenes.add_to_scene(enactor.room.scene, message)
        end
      end
    end
  end
end
