module AresMUSH
  module Fortune
    class FortuneCommand
      include CommandHandler

      attr_accessor :duration

      def parse_args
        #self.fortune = titlecase_arg(cmd.args)
      end

      def check_errors
        puts "Getting a fortune."
      end

      def handle
        
        Fortune.get_fortune()

        message = t('fortune.told_fortune', :name => enactor.name, :fortune_told => fortune_to_tell)
        enactor.room.emit message
        if enactor.room.scene
          Scenes.add_to_scene(enactor.room.scene, message)
        end
      end
    end
  end
end
