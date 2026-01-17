module AresMUSH
  class Character
    attribute :fortunes_told_alltime, :type => DataType::Integer, :default => 0
    attribute :fortunes_told_lately, :type => DataType::Integer, :default => 0

  end
end