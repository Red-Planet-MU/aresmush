module AresMUSH
  module Fortune
    class FishCommand
      include CommandHandler

      attr_accessor :duration

      def parse_args
        #self.fortune = titlecase_arg(cmd.args)

      end

      def check_errors
        return t('fortune.no_biome') if !enactor.room.fish_biome
        return t('fortune.cooldown_on') if enactor.fish_caught_lately >= 3
        return t('fortune.must_be_in_scene') if !enactor.room.scene
      end

      def handle
        fish_to_catch = Fortune.get_fish()
        enactor.update(fortunes_told_lately: enactor.fortunes_told_lately + 1)
        enactor.update(fortunes_told_alltime: enactor.fortunes_told_alltime + 1)
        message = t('fortune.told_fortune', :name => enactor.name, :fortune_told => fortune_to_tell)
        enactor.room.emit message
        Fortune.handle_fortune_given_achievement(enactor)
        if enactor.room.scene
          Scenes.add_to_scene(enactor.room.scene, message)
        end
      end
    end
  end
end
