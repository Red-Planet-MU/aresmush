module AresMUSH
  module Fortune
    class FortuneRequestHandler
      def handle(request)

        {
          chars: LookingForRp.chars_looking_for_rp
        }

      end
    end
  end
end