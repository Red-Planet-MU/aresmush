module AresMUSH
  module Scenes
    class CustomSceneCommands
      def handle(enactor, char, scene, command, args)
        case command
        when 'combat'
          Scenes.emit_pose(char, "#{char.name} dances.", false, true, nil, false, scene.room)
          return { command_response: "You dance." }
        end
        return nil
      end
    end
  end
end