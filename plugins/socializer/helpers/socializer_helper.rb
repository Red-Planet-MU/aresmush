module AresMUSH
  module Socializer

    def self.announce_toggle_on(char)
      char.update(open_scene_announce: "on")
    end

    def self.announce_toggle_off(char)
      char.update(open_scene_announce: "off")
    end

    def self.pal_invite_to_scene(scene, char, enactor)
      if (!scene.participants.include?(char))
        if (!scene.invited.include?(char))
          scene.invited.add char
          message = t('socializer.pal_scene_notify_invite', :name => enactor.name, :num => scene.id)
          Global.notifier.notify_ooc(:scene_message, message) do |notify_char|
            notify_char == char
          end
          Login.notify(char, :scene, message, scene.id)
        end
      end
      #message = t('socializer.pal_scene_notify_invite', :name => enactor.name, :num => scene.id)
      #Global.notifier.notify_ooc(:scene_message, message) do |notify_char|
      #  notify_char == char
      #end
      
      #Login.notify(char, :scene, message, scene.id)
    end

    def self.pal_uninvite_from_scene(scene, char, enactor)
      if (scene.invited.include?(char))
        scene.invited.delete char
      end
      Login.emit_ooc_if_logged_in(char, t('socializer.pal_scene_notify_uninvited', :name => enactor.name, :num => scene.id))
    end

    def self.list_pals(enactor)
      enactor.pals.map { |p| p.name }
    end
  end
end