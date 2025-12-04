module AresMUSH
    module Horse
      class SerumTemplate < ErbTemplateRenderer
        attr_accessor :char
  
        def initialize(char)
          @char = char
          super File.dirname(__FILE__) + "/horse.erb"
        end
  
  
      end
    end
  end
  