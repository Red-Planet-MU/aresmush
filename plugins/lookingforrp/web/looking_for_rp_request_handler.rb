module AresMUSH
  module LookingForRp
    class LookingForRpRequestHandler
      def handle(request)

        {
          chars: LookingForRp.web_list
        }

    end
  end
end