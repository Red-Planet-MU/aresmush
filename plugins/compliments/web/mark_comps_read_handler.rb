module AresMUSH
  module Compliments
    class MarkCompsReadRequestHandler
      def handle(request)
        puts request.args
        enactor = request.enactor
        char_id = request.args['char_id']
        char = Character.find_one_by_name(char_id)

        AresCentral.alts(enactor).all.each do |c|
          if enactor.name == c.name
            Login.mark_notices_read(enactor, :comp)
          end
        end
        {
        }
      end
    end
  end
end