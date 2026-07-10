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
        message = Fortune.get_fish(enactor, enactor.room)
        if message.include? "reels"
          enactor.update(fish_caught_lately: enactor.fish_caught_lately + 1)
          enactor.update(fish_caught_alltime: enactor.fish_caught_alltime + 1)
          Fortune.handle_fish_caught_achievement(enactor)
        end
        enactor.room.emit message
        if enactor.room.scene
          Scenes.add_to_scene(enactor.room.scene, message)
        end
      end
    end
  end
end
