module AresMUSH
  module Fortune
    class FortuneCommand
      include CommandHandler

      attr_accessor :duration

      def parse_args
        #self.fortune = titlecase_arg(cmd.args)
        if !enactor.fortunes_told_alltime
          fortunes_told_lately = 0
          fortunes_told_alltime = 0
        else
          fortunes_told_lately = enactor.fortunes_told_lately
          fortunes_told_alltime = enactor.fortunes_told_alltime
        end
      end

      def check_errors
        if !enactor.fortunes_told_alltime
          fortunes_told_lately = 0
          fortunes_told_alltime = 0
        else
          fortunes_told_lately = enactor.fortunes_told_lately
          fortunes_told_alltime = enactor.fortunes_told_alltime
        end
        return t('fortune.no_machine') if enactor.room.can_use_fortune != true
        return t('fortune.cooldown_on') if fortunes_told_lately > 3
      end

      def handle
        if !enactor.fortunes_told_alltime
          fortunes_told_lately = 0
          fortunes_told_alltime = 0
        else
          fortunes_told_lately = enactor.fortunes_told_lately
          fortunes_told_alltime = enactor.fortunes_told_alltime
        end
        fortune_to_tell = Fortune.get_fortune()
        enactor.update(fortunes_told_lately: fortunes_told_lately + 1)
        enactor.update(fortunes_told_alltime: fortunes_told_alltime + 1)
        message = t('fortune.told_fortune', :name => enactor.name, :fortune_told => fortune_to_tell)
        enactor.room.emit message
        if enactor.room.scene
          Scenes.add_to_scene(enactor.room.scene, message)
        end
      end
    end
  end
end
