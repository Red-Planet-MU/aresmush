module AresMUSH
    module Horse
      class HorseGetCommand
        include CommandHandler


        def check_errors
          return t('horse.not_approved') if !enactor.is_approved?
          return t('fs3skills.not_enough_points') if enactor.luck < 1 && enactor.horse_color
        end
  
        def handle
          if !enactor.horse_color
            Horse.generate_horse(enactor)

            horse_name = enactor.demographic("horse name")
            horse_color = enactor.horse_color
            horse_temperament = enactor.horse_temperament
            client.emit_success t('horse.got_horse', :horse_name => horse_name, :horse_color => horse_color, :horse_temperament => horse_temperament)
          
          else
          
          client.emit_success t('horse.confirm_get_new_horse')
          end
          

        end
      end
    end
  end