module AresMUSH
    module Horse
      class UpdateHorseRequestHandler
        def handle(request)
          char_name_or_id = request.args['char_id']
          char = Character.find_one_by_name(char_name_or_id)
          enactor = request.enactor
          horse_desc = request.args['horse_desc']
          horse_name = request.args['horse_name']
          
          error = Website.check_login(request)
          return error if error
          if enactor.name != char.name
            return { error: t('horse.cant_edit_horse_for_others') }
          end
          if !enactor.is_approved?
            return { error: t('horse.not_approved')}
          end

          enactor.update(horse_desc: horse_desc)
          enactor.update_demographic "horse name", horse_name
          
        end
      end
    end
  end