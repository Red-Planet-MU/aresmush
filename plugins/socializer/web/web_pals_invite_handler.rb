module AresMUSH
  module Socializer
    class WebPalsInviteHandler
      def handle(request)
        puts request.args
        ## probably also need the scene ID
        char_name_or_id = request.auth[:id]
        char = Character.find_one_by_name(char_name_or_id)
        ## Need a helper function to loop through the pal list using only the requesting char id
        Socializer.add_comp([char], comp_msg, Character[comper_id])
        error = Website.check_login(request)
        return error if error
        if comper_id == char_name_or_id
          return { error: t('compliments.cant_comp_self') }
        end
        {
        }
      end
    end
  end
end