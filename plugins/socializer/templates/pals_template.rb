module AresMUSH
  module Socializer
    class PalsTemplate < ErbTemplateRenderer
            
      attr_accessor :enactor, :char
      
      def initialize(enactor)
        @enactor = enactor
        super File.dirname(__FILE__) + "/pals.erb"
      end
      
      def pals_list
        return t('global.none') if @enactor.pals.empty?
        Global.logger.debug "enactor: #{@enactor}, pals: #{@enactor.pals}"
        @enactor.pals.map { |p| p.name }.sort.join(", ")
      end

    end
  end
end
