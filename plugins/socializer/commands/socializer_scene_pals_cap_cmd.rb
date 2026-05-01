module AresMUSH
  module Socializer
    class SocializerScenePalsCapCommand
      include CommandHandler
      
      attr_accessor :scene_num, :char_names, :invited, :pals, :pals_cap_for_scene
      
      def parse_args
        args = cmd.parse_args(ArgParser.arg1_equals_optional_arg2)
        if args.arg1 == "off"
          self.pals_cap_for_scene = "off"
        else
          self.pals_cap_for_scene = integer_arg(args.arg1)
        end
        if args.arg2
          self.scene_num = integer_arg(args.arg2)
        else 
          self.scene_num = enactor_room.scene ? enactor_room.scene.id : nil
        end
      end
      
      def required_args
        [ self.scene_num, self.pals_cap_for_scene ]
      end
      
      def handle        
        Scenes.with_a_scene(self.scene_num, client) do |scene|
          if (!Scenes.can_read_scene?(enactor, scene))
            client.emit_failure t('dispatcher.not_allowed')
            return
          end

          if self.pals_cap_for_scene == "off"
            scene.update(pals_cap: nil)
            client.emit_success t('socializer.cap_unset', :num => self.scene_num) 
          else
            scene.update(pals_cap: self.pals_cap_for_scene)
            client.emit_success t('socializer.cap_set', :cap => self.pals_cap_for_scene, :num => self.scene_num)
          end
        end
      end
    end
  end
end
