module AresMUSH
  module Serum
    class SerumGetCommand
      include CommandHandler

      attr_accessor :serum_name

      def parse_args
        self.serum_name = titlecase_arg(cmd.args)
      end

      def check_errors
        return t('fs3skills.not_enough_points') if enactor.luck < 1
      end

      def handle
        enactor.spend_luck(1)
        Serum.modify_serum(enactor, self.serum_name, 1)
        client.emit_success t('serum.got_serum', :serum => serum_name)
        
      end
    end
  end
end
