module AresMUSH
    class Character < Ohm::Model
      attribute :v_serums_has, :type => DataType::Integer
      attribute :qh_serums_has, :type => DataType::Integer
      attribute :h_serums_has, :type => DataType::Integer
      attribute :a_serums_has, :type => DataType::Integer
      attribute :gc_serums_has, :type => DataType::Integer
      attribute :e_serums_has, :type => DataType::Integer
      attribute :serums_used, :type => DataType::Integer
      attribute :serums_bought, :type => DataType::Integer
  
      attribute :can_buy_serums
  
    end
  
  end
  
  