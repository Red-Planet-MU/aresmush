module AresMUSH
  
  class Combatant < Ohm::Model
    include ObjectModel
      
    attribute :spook_counter, :type => DataType::Integer, :default => 0
    attribute :thrown_from_spooking, :type => DataType::Integer, :default => 0
    attribute :just_calmed, :type => DataType::Boolean, :default => false
    attribute :calm_counter, :type => DataType::Integer, :default => 2
    reference :is_carrying, "AresMUSH::Combatant"
    reference :is_riding_with, "AresMUSH::Combatant"
    
  end
end