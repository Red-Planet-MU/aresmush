module AresMUSH
  class TDSAdvantage < Ohm::Model
    include ObjectModel
    include LearnableAbility
    
    reference :character, "AresMUSH::Character"
    attribute :name
    attribute :rating, :type => DataType::Integer, :default => 0
    
    index :name
    
    def print_rating
      case rating
      when 0
          return ""
      when 1
        return "%xg@%xn"
      when 2
        return "%xg@%xy@%xn"
      when 3
        return "%xg@%xy@%xr@%xn"
      end
    end
    
    def rating_name
      case rating
      when 0
        return t('tdsskills.everyman_rating')
      when 1
        return t('tdsskills.fair_rating')
      when 2
        return t('tdsskills.good_rating')
      when 3
        return t('tdsskills.exceptional_rating')
      end
    end
  end
end