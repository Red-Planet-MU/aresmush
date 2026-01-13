module AresMUSH
  
  class Combatant < Ohm::Model
    include ObjectModel
      
    attribute :serum_lethality_mod, :type => DataType::Integer, :default => 0
    attribute :serum_armor_mod, :type => DataType::Integer, :default => 0
    attribute :serum_init_mod, :type => DataType::Integer, :default => 0
    attribute :serum_damage_lethality_mod, :type => DataType::Integer, :default => 0
    attribute :serum_duration_counter, :type => DataType::Integer, :default => -1
    attribute :last_serum, :default => "Revitalizer"
    attribute :horse_kod, :type => DataType::Boolean, :default => false
    attribute :horse_ko_counter, :type => DataType::Integer, :default => 0
    
  end
end