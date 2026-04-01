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
          if enactor.luck < 1
            return { error: t('fs3skills.not_enough_points') }
          end
          Serum.modify_serum(char, serum_name, 1)
          enactor.update(serums_bought: enactor.serums_bought + 1)
          Serum.handle_serum_obtained_given_achievement(enactor)
          char.spend_luck(1)
          
        end
      end
    end
  end