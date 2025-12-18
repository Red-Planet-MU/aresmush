module AresMUSH
  module LookingForRp
    class LookingForRpRequestHandler
      def handle(request)

        #{
        #  chars: LookingForRp.chars_looking_for_rp
        #}
        lfrp = {}
    
        LookingForRp.chars_looking_for_rp.each do |char|
          lfrp[char.name] = build_web_lfrp_data(char)
        end
          
        {
          lfrp: lfrp.values.sort_by { |v| v[:name] }
        }
      end

      def build_web_lfrp_data(char)
        {
          name: char.name,
          icon: Website.icon_for_char(char),
          status: Website.activity_status(char)
        }
      end

      end
    end
  end
end