module AresMUSH
  class Room
    attribute :can_use_fortune, :type => DataType::Boolean, :default => false
    attribute :can_use_book, :type => DataType::Boolean, :default => false
  end
end