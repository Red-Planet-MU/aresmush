module AresMUSH
    module Horse
      class HorseGetConfirmCommand
        include CommandHandler


        def check_errors
          return t('fs3skills.not_enough_points') if enactor.luck < 1 && enactor.horse_color
        end
  
        def handle
          if enactor.horse_color
            enactor.spend_luck(1)
          end
          Horse.generate_horse(enactor)

          horse_name = enactor.demographic("steed")
          horse_color = enactor.horse_color
          horse_temperament = enactor.horse_temperament
          client.emit_success t('horse.got_horse', :horse_name => horse_name, :horse_color => horse_color, :horse_temperament => horse_temperament)
          

        end
      end
    end
  end