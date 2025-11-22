module AresMUSH
    module Socializer
      class SocializerListPalsCommand
        include CommandHandler
  
        attr_accessor :enactor, :char
  
        def parse_args
          nil
        end
  
        def handle
          
          template = PalsTemplate.new(enactor)
          Global.logger.debug "enactor: #{enactor}"
          client.emit template.render
          
        end
      end
    end
  end