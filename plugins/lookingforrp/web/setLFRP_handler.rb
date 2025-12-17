module AresMUSH
  module LookingForRp
    class setLFRPHandler
      def handle(request)
        puts request.args
        web_enactor = request.auth[:id]
        LookingForRp.set(web_enactor, 1)
        if web_enactor.looking_for_rp_announce == "on"
          Channels.send_to_channel("RP Requests", t('lookingforrp.rp_request_emit', :name => Character[web_enactor].name, :duration => 1))
        end
        error = Website.check_login(request)
        return error if error

        {
        }
      end
    end
  end
end