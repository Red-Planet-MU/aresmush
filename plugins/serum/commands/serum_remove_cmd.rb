module AresMUSH
  module Serum
    class SerumRemoveCommand
      include CommandHandler
  
      attr_accessor :char, :target, :other_client, :serum_name, :serum_type, :serum_has
  
      def parse_args
        args = cmd.parse_args(ArgParser.arg1_equals_arg2)
        self.char = titlecase_arg(args.arg2)
        self.serum_name = titlecase_arg(args.arg1)
        self.serum_type = Serum.find_serums_type(self.serum_name)
        self.serum_has = Serum.find_serums_has(enactor, self.serum_name)
        self.target = Character.find_one_by_name(self.char)
      end
  
      def check_errors
        return "You do not have permission to use that command." if !enactor.has_permission?("manage_serums")
        return t('serum.invalid_serum') if !self.serum_type
        return t('serum.they_dont_have_serum', :name => self.target.name) if Serum.find_serums_has(self.target, self.serum_name) < 1
      end
  
      def handle
        self.other_client = Login.find_game_client(self.target)
        serum_types = Global.read_config("serum", "category")
        Serum.modify_serum(self.target, self.serum_name, -1)
        client.emit_success t('serum.removed_serum', :name => self.target.name, :serum_name => self.serum_name)
        message = t('serum.lost_serum', :name => enactor.name, :serum_name => self.serum_name)
        Login.emit_if_logged_in self.target, message
        Login.notify(self.target, :luck, message, nil)
      end
    end
  end
end