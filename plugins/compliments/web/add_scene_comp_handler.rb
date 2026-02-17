module AresMUSH
  module Compliments
    class AddSceneCompHandler
      def handle(request)
        puts request.args
        comp_msg = request.args['comp_msg']
        scene_id = request.args['id']
        scene = Scene[scene_id]
        comper_id = request.auth['id']
        comp_scenes = Global.read_config("compliments", "comp_scenes")
        targets = scene.participants.to_a
        error = Website.check_login(request)
        return error if error
        if comper_id == char_name_or_id
          return { error: t('compliments.cant_comp_self') }
        end
        
        Compliments.add_comp(targets, comp_msg, Character[comper_id])
        Compliments.handle_comps_given_achievement(Character[comper_id])
        {
        }
      end
    end
  end
end