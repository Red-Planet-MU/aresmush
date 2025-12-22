module AresMUSH
    module Serum
      class GiveSerumRequestHandler
        def handle(request)
          char_name_or_id = request.args['char_id']
          char = Character.find_one_by_name(char_name_or_id)
          serum_name = request.args['serum_type']
          web_target = request.args['target']
          target = Character.named(web_target)
          enactor = request.enactor
          error = Website.check_login(request)
          return error if error
          if Serum.find_serums_has(enactor, serum_name) < 1
            return { error: t('serum.dont_have_serum') }
          end
          if enactor.name != char.name
            return { error: t('serum.cant_give_serum_for_others') }
          end
          if enactor.name = target.name
            return { error: t('serum.cant_give_serum_to_yourself') }
          end
          Serum.modify_serum(char, serum_name, -1)
          Serum.modify_serum(target, serum_name, 1)
          message = t('serum.received_serum', :name => enactor.name, :serum_name => serum_name)
          Login.emit_if_logged_in self.target, message
          Login.notify(self.target, :luck, message, nil)
          
        end
      end
    end
  end
