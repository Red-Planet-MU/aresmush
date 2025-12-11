module AresMUSH
    module Horse
      class HorseGetCommand
        include CommandHandler


        def check_errors
          return t('horse.not_approved') if !enactor.is_approved?
          return t('fs3skills.not_enough_points') if enactor.luck < 1 && enactor.horse_color
        end
  
        def handle
          
          client.emit_success t('horse.confirm_get_new_horse')
          

        end
      end
    end
  end