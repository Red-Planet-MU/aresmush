module AresMUSH
    module Horse
      class HorseDescCommand
        include CommandHandler

        def parse_args
          horsedesc = cmd.args
        end

        def check_errors
          nil
        end
  
        def handle
          
          enactor.update(horse_desc: horsedesc)
          client.emit_success t('horse.desced_horse')
          

        end
      end
    end
  end