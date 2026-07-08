module AresMUSH
  module Serum
    class WebTreatRequestHandler
      def handle(request)
        #Parse args
        enactor = request.enactor
        target_from_web = request.args['target']

        #If no target, target is enactor
        if !target_from_web
          target = enactor
        else 
          target = Character.find_one_by_name(target_from_web)
        end

        wound = FS3Combat.worst_treatable_wound(target)
        
        error = Website.check_login(request)
        return error if error
        
        if FS3Combat.is_in_combat?(target.name)
          return { error: t('fs3combat.use_combat_treat_instead') }
        end
        
        if !wound
          return { error: t('fs3combat.target_has_no_treatable_wounds', :name => target.name) }
        end
        
        message = FS3Combat.treat(target, enactor)
                    
        {message: message_for_web}
      end
    end
  end
end