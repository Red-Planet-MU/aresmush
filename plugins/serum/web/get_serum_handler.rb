module AresMUSH
    module Serum
      class GetSerumRequestHandler
        def handle(request)
          char_name_or_id = request.args['char_id']
          char = Character.find_one_by_name(char_name_or_id)
          serum_name = request.args['serum_type']
          enactor = request.enactor
          error = Website.check_login(request)
          return error if error
          if enactor.name != char.name
            return { error: t('serum.cant_get_serum_for_others') }
          end
          Serum.modify_serum(char, serum_name, 1)
          char.spend_luck(1)
          
        end
      end
    end
  end