module AresMUSH
  module TDSCombat
    class HealingTemplate < ErbTemplateRenderer


      attr_accessor :char
      
      def initialize(char)
        @char = char
        super File.dirname(__FILE__) + "/healing.erb"
      end      
      
      def max_patients
        TDSCombat.max_patients(@char)
      end      
      
      def damage_mod(patient)
        TDSCombat.total_damage_mod(patient)
      end
    end
  end
end

