module AresMUSH
  
  class Combatant < Ohm::Model
    include ObjectModel
      
    attribute :spook_counter, :type => DataType::Integer, :default => 0
    attribute :thrown_from_spooking, :type => DataType::Boolean, :default => false
    attribute :just_calmed, :type => DataType::Boolean, :default => false
    
  end
end