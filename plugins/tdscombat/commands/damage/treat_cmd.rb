module AresMUSH
  module TDSCombat
    class TreatCmd
      include CommandHandler
      
      attr_accessor :name
      
      def parse_args
        self.name = titlecase_arg(cmd.args)
      end
      
      def required_args
        [ self.name ]
      end
      
      def check_in_combat
        return t('tdscombat.use_combat_treat_instead') if TDSCombat.is_in_combat?(enactor.name)
        return nil
      end
      
      def handle
        ClassTargetFinder.with_a_character(self.name, client, enactor) do |model|
          enactor_room.emit_ooc TDSCombat.treat(model, enactor)
        end
      end
    end
  end
end