module AresMUSH
  module Serum
    class TreatRequestHandler
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
        
        #Must have a wound (as currently only serum is healing)
        if !wound
          return { error: t('serum.no_healable_wounds', :target => target.name) }
        end
        
        FS3Combat.treat(model, enactor)
        message_for_web = Serum.non_combat_healing_serum(enactor, target, serum_name, scene)
        enactor.update(serums_used: enactor.serums_used + 1)
        Serum.handle_serum_used_given_achievement(enactor)
                    
        {message: message_for_web}
      end
    end
  end
end