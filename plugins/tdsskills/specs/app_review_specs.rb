module AresMUSH
  module TDSSkills
    describe TDSSkills do 
      
      before do
        stub_translate_for_testing
      end      

      describe :backgrounds do
        before do 
          allow(Global).to receive(:read_config).with("tdsskills", "min_backgrounds") { 2 }
          @char = double
        end
        
        it "should error if too few bg skills" do
          allow(@char).to receive(:tds_background_skills) { [ TDSBackgroundSkill.new() ] }
          review = TDSSkills.backgrounds_review(@char)
          expect(review).to eq "tdsskills.backgrounds_added                        chargen.not_enough"
        end
        
        it "should be OK if enough bg skills" do
          allow(@char).to receive(:tds_background_skills) { [ TDSBackgroundSkill.new(), TDSBackgroundSkill.new() ] }
          review = TDSSkills.backgrounds_review(@char)
          expect(review).to eq "tdsskills.backgrounds_added                        chargen.ok"
        end
      end
      
      describe :ability_rating_check do
        before do 
          allow(Global).to receive(:read_config).with("tdsskills", "max_skills_at_or_above") { { 5 => 2, 7 => 1 } }
          allow(Global).to receive(:read_config).with("tdsskills", "max_attrs_at_or_above") { { 4 => 2, 5 => 1 } }
          allow(Global).to receive(:read_config).with("tdsskills", "max_points_on_attrs") { 14 }
          allow(Global).to receive(:read_config).with("tdsskills", "max_points_on_action") { 20 }
          allow(Global).to receive(:read_config).with("tdsskills", "max_points_on_advantages") { 10 }
          allow(Global).to receive(:read_config).with("tdsskills", "advantages_cost") { 2 }
          @char = double
        end
        
        it "should error if too many skills above 6" do
          allow(@char).to receive(:tds_attributes) { [] }
          allow(@char).to receive(:tds_action_skills) { [ TDSActionSkill.new(rating: 7), 
                                             TDSActionSkill.new(rating: 8) ] }
          allow(@char).to receive(:tds_advantages) { [] }
          review = TDSSkills.ability_rating_review(@char)
          expect(review).to eq "tdsskills.ability_ratings_check%r%Ttdsskills.action_skills_above"
        end

        it "should error if too many skills above 4" do
          allow(@char).to receive(:tds_attributes) { [] }
          allow(@char).to receive(:tds_action_skills) { [ TDSActionSkill.new(rating: 7),
                                             TDSActionSkill.new(rating: 5),
                                             TDSActionSkill.new(rating: 5) ] }
          allow(@char).to receive(:tds_advantages) { [] }
          review = TDSSkills.ability_rating_review(@char)
          expect(review).to eq "tdsskills.ability_ratings_check%r%Ttdsskills.action_skills_above"
        end
        
        it "should error if too many points on attrs" do
          allow(@char).to receive(:tds_action_skills) { [] }
          allow(@char).to receive(:tds_attributes) { [ TDSAttribute.new(rating: 3),
                                             TDSAttribute.new(rating: 4),
                                             TDSAttribute.new(rating: 3),
                                             TDSAttribute.new(rating: 3),
                                             TDSAttribute.new(rating: 4),
                                             TDSAttribute.new(rating: 3) ] }
          allow(@char).to receive(:tds_advantages) { [] }
          review = TDSSkills.ability_rating_review(@char)
          expect(review).to eq "tdsskills.ability_ratings_check%r%Ttdsskills.too_many_attributes"
        end
        
        it "should error if too many points on action skills" do
          allow(@char).to receive(:tds_attributes) { [] }
          allow(@char).to receive(:tds_action_skills) { [ TDSActionSkill.new(rating: 7),
                                             TDSActionSkill.new(rating: 5),
                                             TDSActionSkill.new(rating: 4),
                                             TDSActionSkill.new(rating: 4),
                                             TDSActionSkill.new(rating: 4),
                                             TDSActionSkill.new(rating: 4) ] }
          allow(@char).to receive(:tds_advantages) { [] }
          review = TDSSkills.ability_rating_review(@char)
          expect(review).to eq "tdsskills.ability_ratings_check%r%Ttdsskills.too_many_action_skills"
        end
        
        
        it "should error if too many points on advs" do
          allow(@char).to receive(:tds_action_skills) { [] }
          allow(@char).to receive(:tds_attributes) { [] }
          allow(@char).to receive(:tds_advantages) { [ TDSAdvantage.new(rating: 3),
                                             TDSAdvantage.new(rating: 2),
                                             TDSAdvantage.new(rating: 1) ] }
          review = TDSSkills.ability_rating_review(@char)
          expect(review).to eq "tdsskills.ability_ratings_check%r%Ttdsskills.too_many_advantages"
        end
        
        it "should error if too many attrs above 3" do
          allow(@char).to receive(:tds_action_skills) { [] }
          allow(@char).to receive(:tds_attributes) { [ TDSAttribute.new(rating: 4),
                                             TDSAttribute.new(rating: 4),
                                             TDSAttribute.new(rating: 5) ] }
          allow(@char).to receive(:tds_advantages) { [] }
          review = TDSSkills.ability_rating_review(@char)
          expect(review).to eq "tdsskills.ability_ratings_check%r%Ttdsskills.attributes_above"
        end
        
        it "should error if too many attrs above 4" do
          allow(@char).to receive(:tds_action_skills) { [] }
          allow(@char).to receive(:tds_attributes) { [ TDSAttribute.new(rating: 5),
                                             TDSAttribute.new(rating: 5) ] }
          allow(@char).to receive(:tds_advantages) { [] }
          review = TDSSkills.ability_rating_review(@char)
          expect(review).to eq "tdsskills.ability_ratings_check%r%Ttdsskills.attributes_above"
        end
        
        it "should be OK if not too many high abilities" do
          allow(@char).to receive(:tds_attributes) { [ TDSAttribute.new(rating: 3),
                                             TDSAttribute.new(rating: 4),
                                             TDSAttribute.new(rating: 2) ] }
         allow(@char).to receive(:tds_action_skills) { [ TDSActionSkill.new(rating: 7),
                                            TDSActionSkill.new(rating: 4),
                                            TDSActionSkill.new(rating: 3) ] }
          allow(@char).to receive(:tds_advantages) { [ TDSAdvantage.new(rating: 3),
                                             TDSAdvantage.new(rating: 2) ] }
          review = TDSSkills.ability_rating_review(@char)
          expect(review).to eq "tdsskills.ability_ratings_check                    chargen.ok"
        end
      end

      describe :starting_skills_check do
        before do 
          @char = double
          allow(@char).to receive(:tds_action_skills) { [] }
          allow(StartingSkills).to receive(:get_skills_for_char) { { "A" => 2, "B" => 3 }}
          allow(StartingSkills).to receive(:get_specialties_for_char) { { "A" => [ "X" ] }}
          allow(TDSSkills).to receive(:ability_rating).with(@char, "A") { 3 }
          allow(TDSSkills).to receive(:ability_rating).with(@char, "B") { 3 }
          allow(TDSSkills).to receive(:action_skill_config) { {} }
        end

        it "should warn if missing a starting skill" do
          allow(TDSSkills).to receive(:ability_rating).with(@char, "B") { 0 }
          review = TDSSkills.starting_skills_check(@char)
          expect(review).to eq "tdsskills.starting_skills_check%r%Ttdsskills.missing_starting_skill"
        end
        
        it "should be OK if all skills present" do
          review = TDSSkills.starting_skills_check(@char)
          expect(review).to eq "tdsskills.starting_skills_check                    chargen.ok"
        end
        
        it "should warn if missing a required specialty and over amateur" do
          config = { "specialties" => [ "A" ] }
          allow(TDSSkills).to receive(:action_skill_config) { config }
          allow(@char).to receive(:tds_action_skills) { [ TDSActionSkill.new(name: "Firearms", rating: 3)] }
          review = TDSSkills.starting_skills_check(@char)
          expect(review).to eq "tdsskills.starting_skills_check%r%Ttdsskills.missing_specialty"
        end
        
        it "should warn if missing a required specialty and under amateur" do
          config = { "specialties" => [ "A" ] }
          allow(TDSSkills).to receive(:action_skill_config) { config }
          allow(@char).to receive(:tds_action_skills) { [ TDSActionSkill.new(name: "Firearms", rating: 2)] }
          review = TDSSkills.starting_skills_check(@char)
          expect(review).to eq "tdsskills.starting_skills_check                    chargen.ok"
        end
        
        it "should be OK if specialty present" do
          config = { "specialties" => [ "A" ] }
          allow(TDSSkills).to receive(:action_skill_config) { config }
          allow(@char).to receive(:tds_action_skills) { [ TDSActionSkill.new(name: "Firearms", specialties: [ "X" ])] }
          review = TDSSkills.starting_skills_check(@char)
          expect(review).to eq "tdsskills.starting_skills_check                    chargen.ok"
        end
        
        it "should warn if missing group specialty" do
          allow(@char).to receive(:tds_action_skills) { [ TDSActionSkill.new(name: "A", rating: 3)] }
          review = TDSSkills.starting_skills_check(@char)
          expect(review).to eq "tdsskills.starting_skills_check%r%Ttdsskills.missing_group_specialty"
        end

        it "should not warn if group specialty present" do
          skill = TDSActionSkill.new(name: "A", rating: 3, specialties: [ 'X' ])
          allow(@char).to receive(:tds_action_skills) { [ skill ] }
          review = TDSSkills.starting_skills_check(@char)
          expect(review).to eq "tdsskills.starting_skills_check                    chargen.ok"
        end
      end
      

      describe :unusual_skills_check do
        before do 
          @char = double
          allow(@char).to receive(:tds_background_skills) { [] }
          allow(@char).to receive(:tds_action_skills) { [] }
          allow(@char).to receive(:tds_languages) { [] }
          allow(Global).to receive(:read_config).with("tdsskills", "unusual_skills") { [ "A" ] }
        end

        it "should warn if char has an unusual action skill above everyman" do
          allow(@char).to receive(:tds_action_skills) { [ TDSActionSkill.new(name: "A", rating: 2) ] }
          review = TDSSkills.unusual_skills_check(@char)
          expect(review).to eq "tdsskills.unusual_abilities_check%r%Ttdsskills.unusual_skill"
        end

        it "should not warn if char has an unusual action skill at everyman" do
          allow(@char).to receive(:tds_action_skills) { [ TDSActionSkill.new(name: "A", rating: 1) ] }
          review = TDSSkills.unusual_skills_check(@char)
          expect(review).to eq "tdsskills.unusual_abilities_check                  chargen.ok"
        end
        
        it "should warn if char has an unusual background skill" do
          allow(@char).to receive(:tds_background_skills) { [ TDSBackgroundSkill.new(name: "A", rating: 1) ] }
          review = TDSSkills.unusual_skills_check(@char)
          expect(review).to eq "tdsskills.unusual_abilities_check%r%Ttdsskills.unusual_skill"
        end
        
        it "should warn if char has an unusual language skill" do
          allow(@char).to receive(:tds_languages) { [ TDSLanguage.new(name: "A", rating: 1) ] }
          review = TDSSkills.unusual_skills_check(@char)
          expect(review).to eq "tdsskills.unusual_abilities_check%r%Ttdsskills.unusual_skill"
        end
        
        it "should warn if char has a high background skill" do
          allow(@char).to receive(:tds_background_skills) { [ TDSBackgroundSkill.new(name: "B", rating: 2)]}
          review = TDSSkills.unusual_skills_check(@char)
          expect(review).to eq "tdsskills.unusual_abilities_check%r%Ttdsskills.high_bg"
        end
        
        it "should be OK if no unusual skills present" do
          review = TDSSkills.unusual_skills_check(@char)
          expect(review).to eq "tdsskills.unusual_abilities_check                  chargen.ok"
        end
        
      end
      
    end
  end
end
