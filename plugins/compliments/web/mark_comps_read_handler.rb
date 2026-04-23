module AresMUSH
  module Compliments
    class MarkCompsReadRequestHandler
      def handle(request)
        puts request.args
        enactor = request.enactor
        char_id = request.args['char_id']
        char = Character.find_one_by_name(char_id)

        AresCentral.alts(enactor).each do |c|
          Global.logger.debug "char.name: #{char.name}, c.name: #{c.name}"
          if char.name == c.name
            Login.mark_notices_read(enactor, :comp)
          end
        end
        {
        }
      end
    end
  end
end