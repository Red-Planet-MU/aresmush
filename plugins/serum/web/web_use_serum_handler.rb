module AresMUSH
  module Serum
    class WebUseSerumRequestHandler
      def handle(request)
        #Parse args
        scene = Scene[request.args['id']]
        enactor = request.enactor
        target_from_web = request.args['target_name']
        serum_name = request.args['serum_name']


        #If no target, target is enactor
        if !target_from_web
          target = enactor
        else 
          target = Character.find_one_by_name(target_from_web)
        end

        #As of now, only non-combat serum is healing, so need wound
        wound = FS3Combat.worst_treatable_wound(target)
        
        error = Website.check_login(request)
        return error if error
        
        #Must have that serum
        if Serum.find_serums_has(enactor, serum_name) < 1
          return { error: t('serum.dont_have_serum') }
        end
        
        #Must have a wound (as currently only serum is healing)
        if !wound
          return { error: t('serum.no_healable_wounds', :target => target.name) }
        end
        
        Serum.non_combat_healing_serum(enactor, target, serum_name)
                    
        {}
      end
    end
  end
end