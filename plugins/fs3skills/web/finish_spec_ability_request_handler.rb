module AresMUSH
  module FS3Skills
    class FinishSpecAbilityRequestHandler
      def handle(request)
        Global.logger.debug "Made it to handler"
        ability_arg = request.args['ability']
        spec_arg = request.args['spec']
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
        ClassTargetFinder.with_a_character(char.name, client, enactor.name) do |model|        
          error = FS3Skills.add_specialty(model, ability.name, spec_arg)
          if (error)
            client.emit_failure error
          else
            client.emit_success t('fs3skills.specialty_added', :name => self.specialty)
          end
        end
        {
        }
      end
    end
  end
end