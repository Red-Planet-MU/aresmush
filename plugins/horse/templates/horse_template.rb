module AresMUSH
    module Horse
      class SerumTemplate < ErbTemplateRenderer
        attr_accessor :char
  
        def initialize(char)
          @char = char
          super File.dirname(__FILE__) + "/serum.erb"
        end
  
        def serums_has
          @char.serums_has
        end 
  
      end
    end
  end
  