module AresMUSH
  module Socializer
    class PalsTemplate < ErbTemplateRenderer
            
      attr_accessor :enactor, :char
      
      def initialize(enactor)
        @enactor = enactor
        Global.logger.debug "enactor: #{@enactor}, pals: #{@enactor.pals}"
        super File.dirname(__FILE__) + "/pals.erb"
      end
      
      def pals_list
        Global.logger.debug "enactor: #{@enactor}, pals: #{@enactor.pals}"
        return t('global.none') if @enactor.pals.empty?
        Global.logger.debug "enactor: #{@enactor}, pals: #{@enactor.pals}"
        @enactor.pals.map { |p| p.name }.sort.join(", ")
      end

    end
  end
end
