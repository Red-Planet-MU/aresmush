module AresMUSH
  module FS3Skills
    class LearnSpecAbilityRequestHandler
      def handle(request)
        ability_arg = request.args['ability']
        enactor = request.enactor
        char = Character.named(request.args['char']) || enactor
        
        error = Website.check_login(request)
        return error if error

        request.log_request

        if (!AresCentral.is_alt?(enactor, char))
          return { error: t('dispatcher.not_allowed') }
        end
        
        ability = FS3Skills.find_ability(char, ability_arg)
        specialties = FS3Skills.action_specialties(ability_arg)
        if ability.spec_xp <=7
          ability.update(spec_last_learned: Time.now)
          ability.update(spec_xp: ability.spec_xp + 1)
          FS3Skills.modify_xp(char, -1)
        end
        {
        }
      end
    end
  end
end