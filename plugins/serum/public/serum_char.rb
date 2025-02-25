module AresMUSH
  class Character < Ohm::Model
    attribute :serums_has, :type => DataType::Integer

    attribute :serums_used, :type => DataType::Integer
    attribute :serums_bought, :type => DataType::Integer

    attribute :can_buy_serums

  end

end


