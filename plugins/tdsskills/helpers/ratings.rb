module AresMUSH
  module TDSSkills

    def self.find_ability(char, ability_name)
      ability_name = ability_name.titlecase
      ability_type = TDSSkills.get_ability_type(ability_name)
      case ability_type
      when :attribute
        char.tds_attributes.find(name: ability_name).first
      when :action
        char.tds_action_skills.find(name: ability_name).first
      when :background
        char.tds_background_skills.find(name: ability_name).first
      when :advantage
        char.tds_advantages.find(name: ability_name).first
      when :language
        char.tds_languages.find(name: ability_name).first
      else
        nil
      end
    end
    
    def self.get_linked_attr(ability_name)
      case TDSSkills.get_ability_type(ability_name)
      when :action
        config = TDSSkills.action_skill_config(ability_name)
        return config["linked_attr"]
      when :attribute
        return nil
      else
        return Global.read_config("tdsskills", "default_linked_attr")
      end
    end
    
    def self.skills_census(skill_type)
      skills = {}
      Chargen.approved_chars.each do |c|
        
        if (skill_type == "Action")
          c.tds_action_skills.each do |a|
            add_to_hash(skills, c, a)
          end

        elsif (skill_type == "Background")
          c.tds_background_skills.each do |a|
            add_to_hash(skills, c, a)
          end

        elsif (skill_type == "Language")
          c.tds_languages.each do |a|
            add_to_hash(skills, c, a)
          end
          
        elsif (skill_type == "Advantage")
          c.tds_advantages.each do |a|
            add_to_hash(skills, c, a)
          end
          
        else
          raise "Invalid skill type selected for skill census: #{skill_type}"
        end
      end
      skills = skills.select { |name, people| people.count > 2 }
      skills = skills.sort_by { |name, people| [0-people.count, name] }
      skills
    end
  end
end