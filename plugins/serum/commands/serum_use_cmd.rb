module AresMUSH
  module Serum
    class SerumUseCommand
      include CommandHandler

      attr_accessor :serum_name, :char, :serum_type, :serum_has, :target

      def parse_args
        args = cmd.parse_args(ArgParser.arg1_equals_optional_arg2)
        self.serum_name = titlecase_arg(args.arg1)
        self.char = titlecase_arg(args.arg2)
        self.serum_type = Serum.find_serums_type(self.serum_name)
        self.serum_has = Serum.find_serums_has(enactor, self.serum_name)
        if self.char
          self.target = Character.find_one_by_name(self.char)
        else
          self.target = enactor
        end
      end

      def check_errors
        return t('serum.dont_have_serum') if Serum.find_serums_has(enactor, self.serum_name) < 1
        return t('serum.not_in_combat') if Global.read_config('serum',self.serum_name,'combat_only') = true && enactor.combat
      end      

      def handle
        ClassTargetFinder.with_a_character(self.target_name, client, enactor) do |model|
           template = SerumTemplate.new(model)
           client.emit template.render
        end
      end
    end
  end
end
