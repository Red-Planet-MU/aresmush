module AresMUSH
    module Socializer
      class SocializerChangePalCommand
        include CommandHandler

        attr_accessor :pal, :add_pal
      
      def parse_args
        args = cmd.parse_args(ArgParser.arg1_equals_arg2)
        self.number = trim_arg(args.arg1)
        self.pal = titlecase_arg(args.arg2)
        self.add_pal = cmd.switch_is?("add")
      end
        
        def required_args
          [ self.toggle ]
        end
        
        def handle
          
          ClassTargetFinder.with_a_character(self.pal, client, enactor) do |model|
          if (self.add_pal)
            if (char.pals.include?(model))
              client.emit_failure t('socializer.pal_already_exists', :name => model.name)
              return
            end
            char.pals.add model
            message = t('socializer.pal_added', :name => enactor.name, :pal => model.name)
            #Add something to emit the message
            client.emit_success(message)
            #Jobs.notify(job, message, enactor)
          else
            if (!char.pals.include?(model))
              client.emit_failure t('socializer.pal_doesnt_exist', :name => model.name)
              return
            end
            char.pals.delete model
            message = t('socializer.pal_removed', :name => enactor.name, :pal => model.name)
            client.emit_success(message)
            #add something to emit the message
            #Jobs.notify(job, message, enactor)
          end
        end

        end
      end
  
    end
  end