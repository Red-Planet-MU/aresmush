module AresMUSH
  class Character
    attribute :tds_xp, :type => DataType::Integer, :default => 0
    attribute :tds_luck, :type => DataType::Float, :default => 1
    attribute :tds_cookie_archive, :type => DataType::Integer, :default => 0
    attribute :tds_scene_luck, :type => DataType::Hash, :default => {}
    
    collection :tds_attributes, "AresMUSH::TDSAttribute"
    collection :tds_action_skills, "AresMUSH::TDSActionSkill"
    collection :tds_background_skills, "AresMUSH::TDSBackgroundSkill"
    collection :tds_languages, "AresMUSH::TDSLanguage"
    collection :tds_advantages, "AresMUSH::TDSAdvantage"    
    
    before_delete :delete_abilities
    
    def delete_abilities
      [ self.tds_attributes, self.tds_action_skills, self.tds_background_skills, self.tds_languages, self.tds_advantages].each do |list|
        list.each do |a|
          a.delete
        end
      end
    end
    
    def luck
      self.tds_luck
    end
    
    def xp
      self.tds_xp
    end
    
    def award_luck(amount)
      TDSSkills.modify_luck(self, amount)
    end
    
    def spend_luck(amount)
      TDSSkills.modify_luck(self, -amount)
    end
    
    def award_xp(amount)
      TDSSkills.modify_xp(self, amount)
    end
    
    def spend_xp(amount)
      TDSSkills.modify_xp(self, -amount)
    end
    
    def reset_xp
      self.update(tds_xp: 0)
    end
    
    def roll_ability(ability, mod = 0)
      TDSSkills.one_shot_roll(self, TDSSkills::RollParams.new(ability, mod))
    end
  end
end