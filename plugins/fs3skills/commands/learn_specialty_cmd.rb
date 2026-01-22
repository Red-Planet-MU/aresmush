module AresMUSH

  module FS3Skills
    class LearnSpecialtyCmd
      include CommandHandler
      
      attr_accessor :name

      def parse_args
        self.name = titlecase_arg(cmd.args)
      end

      def required_args
        [ self.name ]
      end
      
      def check_chargen_locked
        return t('fs3skills.must_be_approved') if !enactor.is_approved?
        return nil
      end
      
      def check_xp
        return t('fs3skills.not_enough_xp') if enactor.xp <= 0
      end

      def check_ability_for_specs
        if !FS3Skills.find_ability(enactor, self.name)
          return t('fs3skills.ability_not_found')
        end
      end

      def check_ability_has_specs
        if !FS3Skills.action_specialties(self.name)
          return t('fs3skills.invalid_specialty_skill')
        end
      end
    
      def handle
        ability = FS3Skills.find_ability(enactor, self.name)
        specialties = FS3Skills.action_specialties(self.name)
        if ability.spec_xp <=6
          ability.update(spec_last_learned: Time.now)
          ability.update(spec_xp: ability.spec_xp + 1)
          client.emit_success t('fs3skills.specialty_learned', :name => self.name)
          FS3Skills.modify_xp(enactor, -1) 
        elsif ability.spec_xp == 7
          ability.update(spec_last_learned: Time.now)
          ability.update(spec_xp: ability.spec_xp + 1)
          client.emit_success t('fs3skills.specialty_ready_to_acquire', :name => self.name, :spec_names => specialties.join(", "))
          FS3Skills.modify_xp(enactor, -1) 
        elsif ability.spec_xp == 8 && ability.specialties == []
          client.emit_failure t('fs3skills.specialty_already_ready_to_acquire', :name => self.name, :spec_names => specialties.join(", "))
        else 
          client.emit_failure t('fs3skills.specialty_already_acquired', :name => self.name)
        end
      end
    end
  end
end
