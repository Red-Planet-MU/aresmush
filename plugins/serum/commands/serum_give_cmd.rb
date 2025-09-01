module AresMUSH
    module Serum
      class SerumGiveCommand
        include CommandHandler
  
        attr_accessor :char, :target, :other_client, :serum_name, :serum_type, :serum_has
  
        def parse_args
          args = cmd.parse_args(ArgParser.arg1_equals_arg2)
          self.char = titlecase_arg(args.arg2)
          self.serum_name = titlecase_arg(args.arg1)
          self.serum_type = Serum.find_serums_type(self.serum_name)
          self.serum_has = Serum.find_serums_has(enactor, self.serum_name)
          self.target = Character.find_one_by_name(self.char)
        end
  
        def check_errors
          Global.logger.debug "enactor: #{enactor}. serum_name: #{self.serum_name}"
          return t('serum.dont_have_serum') if Serum.find_serums_has(enactor, self.serum_name) < 1
        end
  
        def handle
          self.other_client = Login.find_game_client(self.target)
          shorties = Global.read_config("serum", "shortcuts")
          serum_types = Global.read_config("serum", "category")
          Global.logger.debug "Shorties: #{shorties}. Serum types: #{serum_types}"
          Serum.modify_serum(self.target, self.serum_name, 1)
          Serum.modify_serum(enactor, self.serum_name, -1)
          client.emit_success t('serum.given_serum', :name => self.target.name, :serum_name => self.serum_name)
          message = t('serum.received_serum', :name => enactor.name, :serum_name => self.serum_name)
          Login.emit_if_logged_in self.target, message
          Login.notify(self.target, :luck, message, nil)
          #self.target.update(serum_has: target.serum_has + 1)
          #self.char.update(serum_has: char.serum_has - 1)
        end
      end
    end
  end