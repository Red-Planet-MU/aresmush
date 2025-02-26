module AresMUSH
  module Serum
    class SerumGiveCommand
      include CommandHandler

      attr_accessor :char, :target, :other_client, :serum_name

      def parse_args
        args = cmd.parse_args(ArgParser.arg1_slash_arg2)
        self.serum_name = titlecase_arg(args.arg1)
        self.char = titlecase_arg(args.arg2)
        self.serum_has = Serum.find_serums_has(enactor, self.serum_name)
        self.target = Character.find_one_by_name(self.char)
      end

      def check_errors
        return t('serum.dont_have_serum') if Serum.find_serums_has(enactor, self.serum_name) < 1
      end

      def handle
        self.other_client = Login.find_client(target)
        self.target.update(serum_has: target.serum_has + 1)
        self.char.update(serum_has: char.serum_has - 1)
      end
    end
  end
end
