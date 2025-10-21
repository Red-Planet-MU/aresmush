module AresMUSH
  class Character
    attribute :fortune_cooldown_expires_at, :type => Ohm::DataTypes::DataType::Time
    attribute :fortunes_told_alltime
    attribute :fortunes_told_for_cron

  end
end