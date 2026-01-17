module AresMUSH
    module Horse
      class GetHorseRequestHandler
        def handle(request)
          char_name_or_id = request.args['char_id']
          char = Character.find_one_by_name(char_name_or_id)
          enactor = request.enactor
          error = Website.check_login(request)
          return error if error
          if enactor.name != char.name
            return { error: t('horse.cant_get_horse_for_others') }
          end
          if !enactor.is_approved?
            return { error: t('horse.not_approved')}
          end
          if enactor.luck < 1 && enactor.horse_color
            return { error: t('fs3skills.not_enough_points') }
          end
          #First horse
          if !enactor.horse_color
            Horse.generate_horse(enactor)

          #New Horse
          else
            enactor.spend_luck(1)
            Horse.generate_horse(enactor)
          end
        end
      end
    end
  end