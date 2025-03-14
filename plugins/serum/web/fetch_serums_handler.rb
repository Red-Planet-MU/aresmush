module AresMUSH
    module Serum
      class FetchSerumRequestHandler
        def handle(request)
          char_name_or_id = request.args[:char_id]
          char = Character.find_one_by_name(char_name_or_id)
          puts "Char: #{char}"
          puts Serum.fetch_serum(char)
          serums = Serum.fetch_serum(char)

          return serums
  
        end
      end
    end
  end