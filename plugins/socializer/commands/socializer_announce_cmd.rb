module AresMUSH
    module Socializer
      class SocializerAnnounceCommand
        include CommandHandler

        attr_accessor :toggle

        def parse_args
          self.toggle = (cmd.args)
        end
        
        def required_args
          [ self.toggle ]
        end
        
        def handle
          if self.toggle == "off"
            Socializer.announce_toggle_off(enactor)
            client.emit_success t('socializer.announce_off')

          elsif self.toggle == "on"
            Socializer.announce_toggle_on(enactor)
            client.emit_success t('socializer.announce_on')
          end
        end
      end
  
    end
  end