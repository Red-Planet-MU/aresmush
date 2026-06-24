module AresMUSH
  class Character
    attribute :open_scene_announce, default: "on"
    set :pals, "AresMUSH::Character"
    attribute :highlight_name, :type => DataType::Boolean, :default => false
    attribute :highlight_name_color, :default => "#6edff6"

  end
end