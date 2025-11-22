module AresMUSH
  
  class Combatant < Ohm::Model
    include ObjectModel
      
    attribute :spook_counter, :type => DataType::Integer, :default => 0
    
  end
end