module AresMUSH
  module Chargen
    class ChargenProfileRequestHandler
      def handle(request)
        id = request.args['id']
        profile_image_to_update = request.args['profile_image_to_set']
        enactor = request.enactor

        error = Website.check_login(request)
        return error if error
                
        char = Character.find_one_by_name id
        if (!char)
          return { error: t('webportal.not_found') }
        end
        
        Global.logger.info "Saving profile image data for #{char.name} by #{enactor.name}."
        
        if (!Chargen.can_approve?(enactor))
          if (char != enactor)
            return { error: t('dispatcher.not_allowed') }
          end
          
          error = Chargen.check_chargen_locked(char)
          return { error: error } if error
        end

        char.update(profile_image: profile_image_to_update.blank? ? nil : profile_image_to_update)
        
        {    
        }
      end
    end
  end
end


