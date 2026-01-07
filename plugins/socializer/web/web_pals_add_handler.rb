module AresMUSH
  module Socializer
    class WebPalsAddHandler
      def handle(request)
        enactor = request.enactor
        target_name = request.args['target']
        target = Character.named(target_name)
        
        error = Website.check_login(request)
        return error if error
        
        if (enactor.pals.include?(target))
          return { error: t('socializer.pal_already_exists', :name => target.name) }
        end

        if !target 
          return { error: t('socializer.no_such_pal', :name => target.name) }
        end

        enactor.pals.add target
                    
        {}
      end
    end
  end
end