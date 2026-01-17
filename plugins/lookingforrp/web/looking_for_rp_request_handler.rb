module AresMUSH
  module LookingForRp
    class LookingForRpRequestHandler
      def handle(request)

        {
        looking_for_rp: LookingForRp.char_names,
        looking_for_rp_chars: LookingForRp.chars_looking_for_rp,
        lfrp_icons: LookingForRp.web_list
        }

      end
    end
  end
end