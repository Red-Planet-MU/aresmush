module AresMUSH
    module Horse
      class HorseGetCommand
        include CommandHandler


        def check_errors
          return t('fs3skills.not_enough_points') if enactor.luck < 1 && enactor.horse_color
        end
  
        def handle
          if enactor.horse_color
            enactor.spend_luck(1)
          end
          
          client.emit_success t('horse.confirm_get_new_horse')
          

        end
      end
    end
  end