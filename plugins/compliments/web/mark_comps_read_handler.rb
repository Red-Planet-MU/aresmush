module AresMUSH
  module Compliments
    class MarkCompsReadRequestHandler
      def handle(request)
        puts request.args
        enactor = request.enactor
        Login.mark_notices_read(enactor, :comp)
        
        {
        }
      end
    end
  end
end