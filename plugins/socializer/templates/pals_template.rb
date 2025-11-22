module AresMUSH
  module Socializer
    class PalsTemplate < ErbTemplateRenderer
            
      attr_accessor :enactor, :char
      
      def initialize(enactor, char)
        @enactor = enactor
        @char = char
        super File.dirname(__FILE__) + "/pals.erb"
      end
      
      def pals_list
        return t('global.none') if @enactor.pals.empty?
        @enactor.pals.map { |p| p.name }.sort.join(", ")
      end

    end
  end
end
