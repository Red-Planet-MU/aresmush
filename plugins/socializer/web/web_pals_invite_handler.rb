module AresMUSH
  module Socializer
    class WebPalsInviteHandler
      def handle(request)
        scene = Scene[request.args['id']]
        enactor = request.enactor


        invitees = enactor.pals.map { |p| p.name }
        
        if (!scene || !invitee)
          return { error: t('webportal.not_found') }
        end
        
        error = Website.check_login(request)
        return error if error
        
        if (!Scenes.can_read_scene?(enactor, scene))
          return { error: t('scenes.scene_is_private') }
        end
        
        if (scene.participants.include?(invitee))
          return { error: t('scenes.scene_already_in_scene') }
        end
        
        invitees.each do |name|
          char = Character.find_one_by_name(name)
          Socializer.pal_invite_to_scene(scene, char, enactor)
        Scenes.invite_to_scene(scene, invitee, enactor)
                    
        {}
      end
    end
  end
end