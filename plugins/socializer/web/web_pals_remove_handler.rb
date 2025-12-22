module AresMUSH
  module Socializer
    class WebPalsRemoveHandler
      def handle(request)
        enactor = request.enactor
        target_name = request.args['target']
        target = Character.named(target_name)
        
        error = Website.check_login(request)
        return error if error
        
        if (!enactor.pals.include?(target))
          return { error: t('socializer.pal_doesnt_exist', :name => target.name) }
        end
        
        enactor.pals.delete target
                    
        {}
      end
    end
  end
end