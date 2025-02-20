module AresMUSH
  module TDSCombat
    describe TDSCombat do
      before do
        stub_translate_for_testing
      end
      
      describe :find_or_create_vehicle do
        before do
          @instance = double
        end
      
        it "should return a vehicle that already exists" do
          v = double
          allow(@instance).to receive(:find_vehicle_by_name).with("abc") { v }
          expect(TDSCombat.find_or_create_vehicle(@instance, "abc")).to eq v
        end
  
        it "should return nil for invalid vehicle type" do
          allow(Global).to receive(:read_config).with("tdscombat", "vehicles") { { "Viper" => {} } }
          allow(@instance).to receive(:find_vehicle_by_name).with("abc") { nil }
          expect(TDSCombat.find_or_create_vehicle(@instance, "abc")).to eq nil
        end
  
        it "should add a new vehicle" do
          allow(Global).to receive(:read_config).with("tdscombat", "vehicles") { { "Viper" => {} } }
          allow(@instance).to receive(:find_vehicle_by_name).with("Viper") { nil }
          v = double
          allow(Vehicle).to receive(:create) do |args|
            expect(args[:combat]).to eq @instance
            expect(args[:vehicle_type]).to eq "Viper"
            v
          end
          expect(TDSCombat.find_or_create_vehicle(@instance, "Viper")).to eq v
        end
        
        it "should find a vehicle with a case-insensitive name" do
          allow(Global).to receive(:read_config).with("tdscombat", "vehicles") { { "AA Battery" => {} } }
          allow(@instance).to receive(:find_vehicle_by_name).with("aa battery") { nil }
          v = double
          allow(Vehicle).to receive(:create) { v }
          expect(TDSCombat.find_or_create_vehicle(@instance, "aa battery")).to eq v
        end
      end
      
      describe :join_vehicle do
        before do
          @vehicle = double
          @combat = double
          @combatant = double
          
          allow(@vehicle).to receive(:name) { "Viper-1" }
          allow(@combatant).to receive(:name) { "Bob" }
          allow(@combatant).to receive(:update)
          allow(@vehicle).to receive(:pilot) { nil }
          allow(@vehicle).to receive(:vehicle_type) { "Viper" }
          allow(TDSCombat).to receive(:emit_to_combat)
          allow(@vehicle).to receive(:update)

          allow(TDSCombat).to receive(:set_weapon)
          allow(TDSCombat).to receive(:vehicle_stat) { [] }
        end
        
        describe "pilot" do
          it "should move the existing pilot to the passenger list if someone else takes over" do
            old_pilot = double
            allow(@vehicle).to receive(:pilot) { old_pilot }
            
            expect(old_pilot).to receive(:update).with(piloting: nil)
            expect(old_pilot).to receive(:update).with(riding_in: @vehicle)
            expect(@vehicle).to receive(:update).with(pilot: @combatant)
            TDSCombat.join_vehicle(@combat, @combatant, @vehicle, "Pilot")
          end
          
          it "should not move pilot if they're the same as the old pilot" do
            allow(@vehicle).to receive(:pilot) { @combatant }
            expect(@vehicle).to receive(:update).with(pilot: @combatant)
            TDSCombat.join_vehicle(@combat, @combatant, @vehicle, "Pilot")
          end
          
          it "should update the pilot's vehicle stat" do
            expect(@combatant).to receive(:update).with(piloting: @vehicle)
            TDSCombat.join_vehicle(@combat, @combatant, @vehicle, "Pilot")
          end
          
          it "should set up default vehicle weapon" do
            expect(TDSCombat).to receive(:vehicle_stat).with("Viper", "weapons") { ["KEW", "Missile"]}
            expect(TDSCombat).to receive(:set_weapon).with(nil, @combatant, "KEW")
            TDSCombat.join_vehicle(@combat, @combatant, @vehicle, "Pilot")
          end
        
          it "should emit to combat" do
            expect(TDSCombat).to receive(:emit_to_combat).with(@combat, "tdscombat.new_pilot")
            TDSCombat.join_vehicle(@combat, @combatant, @vehicle, "Pilot")
          end
        end
        
        describe "passenger" do
          it "should update the pilot's vehicle stat" do
            expect(@combatant).to receive(:update).with(riding_in: @vehicle)
            TDSCombat.join_vehicle(@combat, @combatant, @vehicle, "Passenger")
          end
          
          it "should emit to combat" do
            expect(TDSCombat).to receive(:emit_to_combat).with(@combat, "tdscombat.new_passenger")
            TDSCombat.join_vehicle(@combat, @combatant, @vehicle, "Passenger")
          end
        end
      end
      
      describe :leave_vehicle do
        before do
          @vehicle = double
          @combat = double
          @combatant = double
        
          allow(@vehicle).to receive(:name) { "Viper-1" }
          allow(@combatant).to receive(:name) { "Bob" }
          allow(TDSCombat).to receive(:emit_to_combat)
          allow(@combatant).to receive(:update)
          allow(@vehicle).to receive(:update)
          
          allow(TDSCombat).to receive(:set_default_gear) {}
          allow(Global).to receive(:read_config).with("tdscombat", "default_type") { "soldier" }
        end
      
        it "should remove a pilot" do
          allow(@combatant).to receive(:piloting) { @vehicle }
          expect(@combatant).to receive(:update).with(piloting: nil)
          expect(@vehicle).to receive(:update).with(pilot: nil)
          TDSCombat.leave_vehicle(@combat, @combatant)
        end
        
        it "should emit to combat" do
          allow(@combatant).to receive(:piloting) { @vehicle }
          expect(TDSCombat).to receive(:emit_to_combat).with(@combat, "tdscombat.disembarks_vehicle")
          TDSCombat.leave_vehicle(@combat, @combatant)
        end
      
        it "should remove a passenger" do
          allow(@combatant).to receive(:piloting) { nil }
          allow(@combatant).to receive(:riding_in) { @vehicle }
          expect(@combatant).to receive(:update).with(riding_in: nil)
          TDSCombat.leave_vehicle(@combat, @combatant)
        end
        
        it "should reset gear" do
          allow(@combatant).to receive(:piloting) { @vehicle }
          expect(TDSCombat).to receive(:set_default_gear).with(nil, @combatant, "soldier")
          TDSCombat.leave_vehicle(@combat, @combatant)
        end
        
      end
      
    end
  end
end
