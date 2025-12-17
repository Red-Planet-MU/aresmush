module AresMUSH
  module LookingForRp
    class SetLFRPHandler
      def handle(request)
        puts request.args
        enactor = request.enactor
        Global.logger.debug "Enactor: #{enactor}"
        LookingForRp.set(enactor, 1)
        if enactor.looking_for_rp_announce == "on"
          Channels.send_to_channel("RP Requests", t('lookingforrp.rp_request_emit', :name => enactor.name, :duration => 1))
        end
        error = Website.check_login(request)
        return error if error

        {
        }
      end
    end
  end
end