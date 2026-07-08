module AresMUSH
  module Serum
    class UseSerumRequestHandler
      def handle(request)
        #Parse args
        enactor = request.enactor
        Global.logger.debug ("#{request.args['target']}")
        target_from_web = request.args['target']
        serum_name = request.args['serum_type']


        #If no target, target is enactor
        if !target_from_web
          target = enactor
        else 
          target = Character.find_one_by_name(target_from_web)
        end

        #As of now, only non-combat serum is healing, so need wound
        wound = FS3Combat.worst_serumable_wound(target)
        
        error = Website.check_login(request)
        return error if error
        
        #Must have that serum
        if Serum.find_serums_has(enactor, serum_name) < 1
          return { error: t('serum.dont_have_serum') }
        elsif enactor.combat
          return {error: t('serum.you_are_in_combat') } 
        end
        
        #Must have a wound (as currently only serum is healing)
        if !wound
          return { error: t('serum.no_healable_wounds', :target => target.name) }
        end
        
        message_for_web = Serum.non_combat_healing_serum(enactor, target, serum_name, nil)
        #enactor.update(serums_used: enactor.serums_used + 1) Let's not run this up for test lady
        Serum.handle_serum_used_given_achievement(enactor)
                    
        message_for_web
      end
    end
  end
end