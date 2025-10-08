module AresMUSH
  module Fortune
    class FortuneCommand
      include CommandHandler

      attr_accessor :duration

      def parse_args
        #self.fortune = titlecase_arg(cmd.args)
      end

      def check_errors
        puts "Getting a fortune."
      end

      def handle
        
        Fortune.get_fortune()
      end
    end
  end
end
