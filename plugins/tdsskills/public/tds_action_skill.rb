module AresMUSH
  class TDSActionSkill < Ohm::Model
    include ObjectModel
    include LearnableAbility
    
    reference :character, "AresMUSH::Character"
    attribute :name
    attribute :rating, :type => DataType::Integer, :default => 0
    attribute :specialties, :type => DataType::Array, :default => []
    index :name
    
    def print_rating
      case rating
      when 0
        return ""
      when 1
        return "%xg@%xn"
      when 2
        return "%xg@@%xn"
      when 3
        return "%xg@@%xy@%xn"
      when 4
        return "%xg@@%xy@@%xn"
      when 5
        return "%xg@@%xy@@%xr@%xn"
      when 6
        return "%xg@@%xy@@%xr@@%xn"
      when 7
        return "%xg@@%xy@@%xr@@%xb@%xn"
      when 8
        return "%xg@@%xy@@%xr@@%xb@@%xn"
      end
    end
    
    def rating_name
      case rating
      when 0
        return t('tdsskills.incapable_rating')
      when 1
        return t('tdsskills.everyman_rating')
      when 2
        return t('tdsskills.fair_rating')
      when 3
        return t('tdsskills.competent_rating')
      when 4
        return t('tdsskills.good_rating')
      when 5
        return t('tdsskills.great_rating')
      when 6
        return t('tdsskills.exceptional_rating')
      when 7
        return t('tdsskills.amazing_rating')
      when 8
        return t('tdsskills.legendary_rating')
      end
    end
  end
end