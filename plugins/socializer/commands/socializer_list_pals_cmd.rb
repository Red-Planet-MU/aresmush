module AresMUSH
    module Socializer
      class SocializerListPalsCommand
        include CommandHandler
  
        attr_accessor :enactor, :char
  
        def parse_args
          nil
        end
  
        def handle
          ClassTargetFinder.with_a_character(enactor, client) do |model|
             template = SerumTemplate.new(model)
             client.emit template.render
          end
        end
      end
    end
  end