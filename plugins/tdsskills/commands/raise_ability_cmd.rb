module AresMUSH

  module TDSSkills
    class RaiseAbilityCmd
      include CommandHandler
      
      attr_accessor :name

      def parse_args
        self.name = titlecase_arg(cmd.args)
      end

      def required_args
        [ self.name ]
      end
      
      def check_chargen_locked
        Chargen.check_chargen_locked(enactor)
      end
      
      def handle
        current_rating = TDSSkills.ability_rating(enactor, self.name)
        mod = cmd.root_is?("raise") ? 1 : -1
        new_rating = current_rating + mod
        
        error = TDSSkills.check_rating(self.name, new_rating)
        if (error)
          client.emit_failure error
          return
        end
      
        error = TDSSkills.set_ability(enactor, self.name, new_rating)
        if (error)
          client.emit_failure error
        else
          client.emit_success TDSSkills.ability_raised_text(enactor, self.name)
        end
      end
    end
  end
end
