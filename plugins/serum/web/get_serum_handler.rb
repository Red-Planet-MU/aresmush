module AresMUSH
    module Serum
      class GetSerumRequestHandler
        def handle(request)
          char_name_or_id = request.args[:char_id]
          char = Character.find_one_by_name(char_name_or_id)
          serum_name = request.args[:serum_type]
          puts "Char: #{char}"
          comper_id = request.auth[:id]
          Serum.modify_serum(char, serum_name, 1)
          error = Website.check_login(request)
          return error if error
          if comper_id == char_name_or_id
            return { error: t('compliments.cant_comp_self') }
        end
      end
    end
  end