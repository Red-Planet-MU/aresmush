module AresMUSH
  module TDSSkills
    module AbilityPointCounter
      def self.total_points(char)
        return self.points_on_attrs(char) + self.points_on_action(char) + 
           self.points_on_background(char) + self.points_on_language(char) +
           self.points_on_specialties(char) + self.points_on_advantages(char)
      end
      
      def self.points_on_attrs(char)
        char.tds_attributes.inject(0) { |count, a| count + (a.rating > 2 ? (a.rating - 2) * 2 : 0) }
      end

      def self.points_on_action(char)
        char.tds_action_skills.inject(0) { |count, a| count + (a.rating > 1 ? a.rating - 1 : 0) }
      end
      
      def self.points_on_specialties(char)
        char.tds_action_skills.inject(0) { |count, a| count + 
            (a.specialties.count > 1 ? a.specialties.count - 1 : 0) }
      end
      
      def self.points_on_background(char)
        free = Global.read_config("tdsskills", "free_backgrounds")
        count = char.tds_background_skills.inject(0) { |count, a| count + a.rating }
        count > free ? count - free : 0
      end

      def self.points_on_language(char)
        free = Global.read_config("tdsskills", "free_languages")
        count = char.tds_languages.inject(0) { |count, a| count + a.rating }
        count > free ? count - free : 0
      end
      
      def self.points_on_advantages(char)
        cost = Global.read_config("tdsskills", "advantages_cost")
        char.tds_advantages.inject(0) { |count, a| count + (a.rating * cost) }
      end

    end
  end
end 