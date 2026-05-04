module AresMUSH
  module Socializer
    class SocializerSceneInvitePalsCommand
      include CommandHandler
      
      attr_accessor :scene_num, :char_names, :invited, :pals
      
      def parse_args
        if cmd.args
          if cmd.args.to_i == 0
            args = cmd.parse_args(ArgParser.arg1_equals_optional_arg2)
            self.char_names = list_arg(args.arg1)
            if args.arg2
              self.scene_num = integer_arg(args.arg2)
            else 
              self.scene_num = enactor_room.scene ? enactor_room.scene.id : nil
            end
          else 
            self.scene_num = integer_arg(cmd.args)
          end
        else
          self.char_names = enactor.pals.map { |p| p.name }
          self.scene_num = enactor_room.scene ? enactor_room.scene.id : nil
        end
          self.invited = cmd.switch_is?("invite")
      end
      
      def required_args
        [ self.scene_num ]
      end
      
      def handle        
        Scenes.with_a_scene(self.scene_num, client) do |scene|
          if (!Scenes.can_read_scene?(enactor, scene))
            client.emit_failure t('dispatcher.not_allowed')
            return
          end
          if (self.invited)
            self.char_names.each do |name|
              char = Character.find_one_by_name(name)

              if (!char)
                client.emit_failure t("db.object_not_found")
                return
              end

              if (!scene.participants.include?(char))
                Socializer.pal_invite_to_scene(scene, char, enactor)
                client.emit_success t('socializer.scene_pal_invited', :name => char.name)
              end
            end
          else
            scene.invited.each do |char|
              Socializer.pal_uninvite_from_scene(scene, char, enactor)
              client.emit_success t('socializer.scene_pal_uninvited', :name => char.name)  
            end
          end

        end
      end
    end
  end
end
