module AresMUSH
    module Horse
      class HorseDescCommand
        include CommandHandler

        attr_accessor :horse_desc

        def parse_args
          self.horse_desc = cmd.args
        end

        def check_errors
          nil
        end
  
        def handle
          
          enactor.update(horse_desc: self.horse_desc)
          client.emit_success t('horse.desced_horse')
          

        end
      end
    end
  end