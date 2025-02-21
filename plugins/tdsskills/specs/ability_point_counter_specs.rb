module AresMUSH
  module TDSSkills
    describe TDSSkills do

      before do
        allow(Global).to receive(:read_config).with("tdsskills", "free_languages") { 3 }
      end
      
      describe :points_on_attrs do
        before do
          @char = double
        end
        
        it "should count anything above average" do
          attrs = [ TDSAttribute.new(rating: 5), 
                    TDSAttribute.new(rating: 2), 
                    TDSAttribute.new(rating: 3),
                    TDSAttribute.new(rating: 4) ]
          allow(@char).to receive(:tds_attributes) { attrs }
          expect(AbilityPointCounter.points_on_attrs(@char)).to eq 12
        end
        
        it "should not count average or below average" do
          attrs = [ TDSAttribute.new(rating: 1), 
                    TDSAttribute.new(rating: 2), 
                    TDSAttribute.new(rating: 2),
                    TDSAttribute.new(rating: 2) ]
          allow(@char).to receive(:tds_attributes) { attrs }
          expect(AbilityPointCounter.points_on_attrs(@char)).to eq 0
        end
      end
      
      describe :points_on_action do
        before do
          @char = double
        end
        
        it "should count anything above everyman" do
          action = [ TDSActionSkill.new(rating: 2), 
                     TDSActionSkill.new(rating: 3), 
                     TDSActionSkill.new(rating: 4),
                     TDSActionSkill.new(rating: 5) ]
          allow(@char).to receive(:tds_action_skills) { action }
          expect(AbilityPointCounter.points_on_action(@char)).to eq 10
        end
        
        it "should not count everyman or poor" do
          action = [ TDSActionSkill.new(rating: 1), 
                     TDSActionSkill.new(rating: 1), 
                     TDSActionSkill.new(rating: 1),
                     TDSActionSkill.new(rating: 0) ]
          allow(@char).to receive(:tds_action_skills) { action }
          expect(AbilityPointCounter.points_on_action(@char)).to eq 0
        end
      end

      describe :points_on_background do
        before do
          @char = double
          allow(Global).to receive(:read_config).with("tdsskills", "free_backgrounds") { 5 }
        end
        
        it "should count past the free ones" do
          bg = [ TDSBackgroundSkill.new(rating: 3), 
                 TDSBackgroundSkill.new(rating: 3), 
                 TDSBackgroundSkill.new(rating: 2) ]
          allow(@char).to receive(:tds_background_skills) { bg }
          expect(AbilityPointCounter.points_on_background(@char)).to eq 3
        end
        
        it "should not count if below free ones" do
          bg = [ TDSBackgroundSkill.new(rating: 2), 
                 TDSBackgroundSkill.new(rating: 1), 
                 TDSBackgroundSkill.new(rating: 1) ]
          allow(@char).to receive(:tds_background_skills) { bg }
          expect(AbilityPointCounter.points_on_background(@char)).to eq 0
        end
      end
      
      describe :points_on_language do
        before do
          @char = double
          allow(Global).to receive(:read_config).with("tdsskills", "free_languages") { 4 }
        end
        
        it "should count past the free ones" do
          lang = [ TDSLanguage.new(rating: 3), 
                   TDSLanguage.new(rating: 3), 
                   TDSLanguage.new(rating: 2) ]
          allow(@char).to receive(:tds_languages) { lang }
          expect(AbilityPointCounter.points_on_language(@char)).to eq 4
        end
        
        it "should not count if below free ones" do
          lang = [ TDSLanguage.new(rating: 2), 
                   TDSLanguage.new(rating: 1) ]
          allow(@char).to receive(:tds_languages) { lang }
          expect(AbilityPointCounter.points_on_language(@char)).to eq 0
        end
      end
      
      describe :points_on_specialties do
        before do
          @char = double
        end
        
        it "should count abilities with more than one specialty" do
          action = [ TDSActionSkill.new(specialties: [ "A", "B" ]), 
                     TDSActionSkill.new(specialties: ["C", "D", "E"] ) ]
          allow(@char).to receive(:tds_action_skills) { action }
          expect(AbilityPointCounter.points_on_specialties(@char)).to eq 3
        end
        
        it "should not count first specialties" do
          action = [ TDSActionSkill.new(specialties: [ "A" ]), 
                     TDSActionSkill.new(specialties: [ "C" ] ) ]
          allow(@char).to receive(:tds_action_skills) { action }
          expect(AbilityPointCounter.points_on_specialties(@char)).to eq 0
        end
      end
      
    end
  end
end
