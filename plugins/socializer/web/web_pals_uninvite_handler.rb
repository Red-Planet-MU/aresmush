module AresMUSH
  module Socializer
    class WebPalsUninviteHandler
      def handle(request)
        scene = Scene[request.args['id']]
        enactor = request.enactor
        
        error = Website.check_login(request)
        return error if error
        if (!Scenes.can_read_scene?(enactor, scene))
          return { error: t('scenes.scene_is_private') }
        end

        scene.update(pals_cap: nil)
        
        #if (scene.participants.include?(invitee))
        #  return { error: t('scenes.scene_already_in_scene') }
        #end

        scene.invited.each do |char|
          Socializer.pal_uninvite_from_scene(scene, char, enactor)
        end
                    
        {}
      end
    end
  end
end