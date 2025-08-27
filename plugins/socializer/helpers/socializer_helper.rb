module AresMUSH
  module Socializer

    def self.announce_toggle_on(char)
      char.update(open_scene_announce: "on")
    end

    def self.announce_toggle_off(char)
      char.update(open_scene_announce: "off")
    end

  end
end