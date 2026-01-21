module AresMUSH
  module Socializer
    class WebManagePalsHandler
      def handle(request)
        enactor = request.enactor
        #target_name = request.args['target']
        #target = Character.named(target_name)

        pal_names = request.args['pals'] || []
        pals = []
        

        error = Website.check_login(request)
        return error if error
        
        current_pals = enactor.pals.map { |p| p.name }
        enactor.pals.each do |p|
          if !pal_names.include?(p)
            enactor.pals.delete p
          end
        end
        pal_names.each do |p|
          pal = Character.find_one_by_name(p.strip)
          if (pal)
            enactor.pals.add pal
          end
        end
                    
        {}
      end
    end
  end
end