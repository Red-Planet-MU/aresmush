module AresMUSH
  module TDSCombat
    describe TDSCombat do
      before do
        stub_translate_for_testing
      end
      
      describe :reset_for_new_turn do
        before do 
          @combatant = double
          allow(@combatant).to receive(:log)
          allow(@combatant).to receive(:name) { "Trooper" }
          allow(@combatant).to receive(:update)
          allow(@combatant).to receive(:is_aiming?) { false }
          allow(@combatant).to receive(:is_subdued?) { false }
          allow(@combatant).to receive(:freshly_damaged) { false }
          allow(@combatant).to receive(:action_klass) { nil }
          allow(@combatant).to receive(:is_ko) { false }
          allow(@combatant).to receive(:luck) { "Defense" }
          allow(TDSCombat).to receive(:reset_stress)
          allow(TDSCombat).to receive(:check_for_ko)
        end
        
        it "should reset luck spent" do
          expect(@combatant).to receive(:update).with(luck: nil)
          TDSCombat.reset_for_new_turn(@combatant)
        end
        
        it "should reset posed" do
          expect(@combatant).to receive(:update).with(posed: false)
          TDSCombat.reset_for_new_turn(@combatant)
        end
        
        it "should reset recoil" do
          expect(@combatant).to receive(:update).with(recoil: 0)
          TDSCombat.reset_for_new_turn(@combatant)
        end
        
        it "should reset fresh damage" do
          expect(@combatant).to receive(:update).with(freshly_damaged: false)
          TDSCombat.reset_for_new_turn(@combatant)
        end
        
        it "should reset aiming if they aren't still aiming" do 
          allow(@combatant).to receive(:is_aiming?) { true }
          allow(@combatant).to receive(:action) { AttackAction.new(@combatant, "") }
          expect(@combatant).to receive(:update).with(aim_target: nil)
          TDSCombat.reset_for_new_turn(@combatant)
        end

        it "should not reset aiming if they're still aiming" do 
          allow(@combatant).to receive(:is_aiming?) { true }
          allow(@combatant).to receive(:action_klass) { "AresMUSH::TDSCombat::AimAction" }
          expect(@combatant).to_not receive(:update).with(aim_target: nil)
          TDSCombat.reset_for_new_turn(@combatant)
        end
        
        it "should reset subdued if their attacker is no longer subduing them" do
          subduer = double
          allow(@combatant).to receive(:is_subdued?) { false }
          expect(@combatant).to receive(:update).with(subdued_by: nil)
          TDSCombat.reset_for_new_turn(@combatant)
        end

        it "should not reset subdued if their attacker is still subduing them" do
          subduer = double
          allow(@combatant).to receive(:is_subdued?) { true }
          expect(@combatant).to_not receive(:update).with(subdued_by: nil)
          TDSCombat.reset_for_new_turn(@combatant)
        end
        
        it "should lower stress" do
          expect(TDSCombat).to receive(:reset_stress).with(@combatant)
          TDSCombat.reset_for_new_turn(@combatant)
        end
        
        it "should remove a KO'ed NPC" do
          allow(@combatant).to receive(:is_ko) { true }
          allow(@combatant).to receive(:is_npc?) { true }
          combat = double
          allow(@combatant).to receive(:combat) { combat }
          expect(TDSCombat).to receive(:leave_combat).with(combat, @combatant)
          TDSCombat.reset_for_new_turn(@combatant)
        end
      end
      
      describe :reset_stress do 
        before do
          @combatant = double
          allow(@combatant).to receive(:log)
          allow(@combatant).to receive(:name) { "Bob" }
          allow(@combatant).to receive(:stress) { 0 }
          allow(Global).to receive(:read_config).with("tdscombat", "composure_skill") { "Composure" }
        end
        
        it "should reduce stress by 1 even if roll fails" do
          allow(@combatant).to receive(:stress) { 3 }
          allow(@combatant).to receive(:roll_ability).with("Composure") { 0 }
          expect(@combatant).to receive(:update).with(stress: 2)
          TDSCombat.reset_stress(@combatant)
        end
        
        it "should reduce stress by roll result further" do
          allow(@combatant).to receive(:stress) { 3 }
          allow(@combatant).to receive(:roll_ability).with("Composure") { 2 }
          expect(@combatant).to receive(:update).with(stress: 0)
          TDSCombat.reset_stress(@combatant)
        end
        
        it "should not reduce stress below 0" do
          allow(@combatant).to receive(:stress) { 1 }
          allow(@combatant).to receive(:roll_ability).with("Composure") { 2 }
          expect(@combatant).to receive(:update).with(stress: 0)
          TDSCombat.reset_stress(@combatant)
        end
      end
      
      describe :check_for_ko do
        before do
          @combatant = double
          allow(@combatant).to receive(:log)
          allow(@combatant).to receive(:name) { "Bob" }
          allow(@combatant).to receive(:is_ko) { false }
          allow(@combatant).to receive(:freshly_damaged) { true }
          allow(@combatant).to receive(:total_damage_mod) { -2.0 }
          allow(@combatant).to receive(:is_npc?) { false }
          allow(@combatant).to receive(:name) { "Bob" }
          allow(@combatant).to receive(:damaged_by) { [ "Bob" ] }
        end
        
        it "should do nothing if already KOd" do
          allow(@combatant).to receive(:is_ko) { true }
          TDSCombat.check_for_ko(@combatant)
        end
        
        it "should do nothing if only slightly injured" do
          allow(@combatant).to receive(:total_damage_mod) { -0.99 }
          TDSCombat.check_for_ko(@combatant)
        end
        
        it "should do nothing if not freshly damaged" do
          allow(@combatant).to receive(:freshly_damaged) { false }
          TDSCombat.check_for_ko(@combatant)
        end
        
        it "should KO the person if roll fails" do
          combat = double
          expect(TDSCombat).to receive(:make_ko_roll).with(@combatant) { 0 }
          expect(@combatant).to receive(:update).with(action_klass: nil)
          expect(@combatant).to receive(:update).with(action_args: nil)
          expect(@combatant).to receive(:update).with(is_ko: true)
          allow(@combatant).to receive(:combat) { combat }
          expect(TDSCombat).to receive(:emit_to_combat).with(combat, "tdscombat.is_koed", nil, true)
          TDSCombat.check_for_ko(@combatant)
        end
        
        it "should auto-ko a NPC with enough damage" do
          combat = double
          allow(@combatant).to receive(:total_damage_mod) { -7.1 }
          allow(@combatant).to receive(:is_npc?) { true }
          expect(TDSCombat).to_not receive(:make_ko_roll)
          expect(@combatant).to receive(:update).with(action_klass: nil)
          expect(@combatant).to receive(:update).with(action_args: nil)
          expect(@combatant).to receive(:update).with(is_ko: true)
          allow(@combatant).to receive(:combat) { combat }
          expect(TDSCombat).to receive(:emit_to_combat).with(combat, "tdscombat.is_koed", nil, true)
          TDSCombat.check_for_ko(@combatant)
        end
        
        it "should not auto-ko a PC with enough damage" do
          combat = double
          allow(@combatant).to receive(:total_damage_mod) { -10.1 }
          allow(@combatant).to receive(:is_npc?) { false }
          expect(TDSCombat).to receive(:make_ko_roll).with(@combatant) { 1 }
          TDSCombat.check_for_ko(@combatant)
        end
        
        it "should not KO the person if their roll succeeds" do
          expect(TDSCombat).to receive(:make_ko_roll).with(@combatant) { 1 }
          TDSCombat.check_for_ko(@combatant)
        end
      end
      
      describe :check_for_unko do
        before do
          @combatant = double
          allow(@combatant).to receive(:log)
          allow(@combatant).to receive(:is_ko) { true }
        end
        
        it "should do nothing if not KOd" do
          allow(@combatant).to receive(:is_ko) { false }
          TDSCombat.check_for_unko(@combatant)
        end
        
        it "should do nothing if KO roll fails" do
          expect(TDSCombat).to receive(:make_ko_roll).with(@combatant, 3) { 0 }
          TDSCombat.check_for_unko(@combatant)
        end
        
        it "should un-KO the person if their roll succeeds" do
          combat = double
          allow(@combatant).to receive(:name) { "Bob" }
          expect(@combatant).to receive(:update).with(is_ko: false)
          expect(TDSCombat).to receive(:make_ko_roll).with(@combatant, 3) { 1 }
          allow(@combatant).to receive(:combat) { combat }
          expect(TDSCombat).to receive(:emit_to_combat).with(combat, "tdscombat.is_no_longer_koed", nil, true) {}
          TDSCombat.check_for_unko(@combatant)
        end
      end
      
      describe :make_ko_roll do
        before do
          @combatant = double
          allow(@combatant).to receive(:log)
          allow(@combatant).to receive(:name) { "Bob" }
          allow(@combatant).to receive(:total_damage_mod) { -2 }
          allow(@combatant).to receive(:is_npc?) { true }
          allow(Global).to receive(:read_config).with("tdscombat", "pc_knockout_bonus") { 3 }
        end
        
        it "should roll vehicle toughness if in a vehicle" do
          vehicle = double
          allow(Global).to receive(:read_config).with("tdscombat", "composure_skill") { "Composure" }
          allow(vehicle).to receive(:vehicle_type) { "Viper" }
          allow(@combatant).to receive(:is_in_vehicle?) { true }
          allow(@combatant).to receive(:vehicle) { vehicle }
          allow(TDSCombat).to receive(:vehicle_stat).with("Viper", "toughness") { 5 }
          # Total mod = +5 for vehicle, -4 for damage (-2 x 2)
          expect(@combatant).to receive(:roll_ability).with("Composure", 1) { 1 }
          expect(TDSCombat.make_ko_roll(@combatant)).to eq 1
        end
        
        it "should roll personal toughness if not in a vehicle" do
          allow(@combatant).to receive(:is_in_vehicle?) { false }
          allow(Global).to receive(:read_config).with("tdscombat", "composure_skill") { "Composure" }
          expect(@combatant).to receive(:roll_ability).with("Composure", -4) { 1 }
          expect(TDSCombat.make_ko_roll(@combatant)).to eq 1
        end
        
        it "should give PCs a bonus to knockout" do
          allow(@combatant).to receive(:is_npc?) { false }
          allow(@combatant).to receive(:is_in_vehicle?) { false }
          allow(Global).to receive(:read_config).with("tdscombat", "composure_skill") { "Composure" }
          expect(@combatant).to receive(:roll_ability).with("Composure", -1) { 1 }
          expect(TDSCombat.make_ko_roll(@combatant)).to eq 1
        end
      end
      
      describe :ai_action do
        before do
          @combatant = double
          allow(@combatant).to receive(:log)
          @client = double
          @combat = double
          allow(TDSCombat).to receive(:check_ammo) { true }
          allow(@combatant).to receive(:is_subdued?) { false }
        end
        
        it "should choose reload if out of ammo" do
          expect(TDSCombat).to receive(:check_ammo).with(@combatant, 1) { false }
          expect(TDSCombat).to receive(:set_action).with(nil, @combat, @combatant, TDSCombat::ReloadAction, "")
          TDSCombat.ai_action(@combat, @combatant)
        end
        
        it "should choose escape if subdued" do
          allow(@combatant).to receive(:is_subdued?) { true }
          expect(TDSCombat).to receive(:set_action).with(nil, @combat, @combatant, TDSCombat::EscapeAction, "")
          TDSCombat.ai_action(@combat, @combatant)
        end

        describe "attack" do
          before do
            @target1 = double
            @target2 = double
            allow(@target2).to receive(:name) { "Bob" }
            allow(@combatant).to receive(:team) { 1 }
            allow(@combatant).to receive(:weapon) { "Rifle" }
            allow(@target1).to receive(:team) { 1 }
            allow(@target2).to receive(:team) { 2 }
            allow(TDSCombat).to receive(:weapon_stat) { "" }
            allow(TDSCombat).to receive(:find_ai_target) { @target2 }
          end   
                   
          it "should attack a random target" do
            expect(TDSCombat).to receive(:find_ai_target).with(@combat, @combatant) { @target2 }
            expect(TDSCombat).to receive(:set_action).with(nil, @combat, @combatant, TDSCombat::AttackAction, "Bob")
            TDSCombat.ai_action(@combat, @combatant)
          end
          
          it "should do nothing if no valid target found" do
            expect(TDSCombat).to receive(:find_ai_target).with(@combat, @combatant) { nil }
            expect(TDSCombat).to receive(:set_action).with(nil, @combat, @combatant, TDSCombat::PassAction, "")
            TDSCombat.ai_action(@combat, @combatant)
          end
          
          it "should use the explode action for explosive weapons" do
            expect(TDSCombat).to receive(:weapon_stat).with("Rifle", "weapon_type") { "Explosive" }            
            expect(TDSCombat).to receive(:set_action).with(nil, @combat, @combatant, TDSCombat::ExplodeAction, "Bob")

            TDSCombat.ai_action(@combat, @combatant)
          end
          
          it "should use the suppress action for suppressive weapons" do
            expect(TDSCombat).to receive(:weapon_stat).with("Rifle", "weapon_type") { "Suppressive" }            
            expect(TDSCombat).to receive(:set_action).with(nil, @combat, @combatant, TDSCombat::SuppressAction, "Bob")

            TDSCombat.ai_action(@combat, @combatant)
          end
          
        end
      end
      
      describe :find_ai_target do
        before do
          @attacker = double
          @combat = double
          @target1 = double("t1")
          @target2 = double("t2")
          @target3 = double("t3")
          allow(@target1).to receive(:stance) { "Normal" }
          allow(@target2).to receive(:stance) { "Normal" }
          allow(@target3).to receive(:stance) { "Normal" }
          allow(@attacker).to receive(:team) { 1 }
          allow(@combat).to receive(:active_combatants) { [@attacker, @target1, @target2, @target3] }
          allow_any_instance_of(Array).to receive(:shuffle) do |instance|
            instance
          end
        end
        
        it "should find a random target on any other team if no team target specified" do
          allow(@combat).to receive(:team_targets) { {} }
          allow(@target1).to receive(:team) { 1 }
          allow(@target2).to receive(:team) { 2 }
          allow(@target3).to receive(:team) { 3 }

          target = TDSCombat.find_ai_target(@combat, @attacker)
          expect(target).to eq @target2
        end
        
        it "should omit targets that are hidden " do
          allow(@combat).to receive(:team_targets) { {} }
          allow(@target1).to receive(:team) { 1 }
          allow(@target2).to receive(:team) { 2 }
          allow(@target3).to receive(:team) { 3 }
          allow(@target2).to receive(:stance) { "Hidden" }

          target = TDSCombat.find_ai_target(@combat, @attacker)
          expect(target).to eq @target3
        end
        
        it "should find a random target on the specified team target teams" do
          allow(@combat).to receive(:team_targets) { { "1" => [ 3, 4 ] } }
          allow(@target1).to receive(:team) { 1 }
          allow(@target2).to receive(:team) { 2 }
          allow(@target3).to receive(:team) { 3 }

          target = TDSCombat.find_ai_target(@combat, @attacker)
          expect(target).to eq @target3
        end
        
        it "should return nil if no valid targets found" do
          allow(@combat).to receive(:team_targets) { { "1" => [ 4 ] } }
          
          allow(@target1).to receive(:team) { 1 }
          allow(@target2).to receive(:team) { 2 }
          allow(@target3).to receive(:team) { 3 }

          target = TDSCombat.find_ai_target(@combat, @attacker)
          expect(target).to eq nil
        end
      end
      
      describe :stopped_by_cover? do
        before do 
          @combatant = double
          allow(@combatant).to receive(:log)
        end
        
        it "should bypass cover if enough successes on attack roll" do
          allow(TDSCombat).to receive(:rand) { 0 }
          expect(TDSCombat.stopped_by_cover?(3, @combatant)).to be false
        end
        
        it "should have 50% cover for a marginal attack roll" do
          allow(TDSCombat).to receive(:rand) { 51 }
          expect(TDSCombat.stopped_by_cover?(0, @combatant)).to be false
          expect(TDSCombat.stopped_by_cover?(1, @combatant)).to be false
          allow(TDSCombat).to receive(:rand) { 49 }
          expect(TDSCombat.stopped_by_cover?(0, @combatant)).to be true
          expect(TDSCombat.stopped_by_cover?(1, @combatant)).to be true
        end
        
        it "should have 25% cover for a decent attack roll" do

          allow(TDSCombat).to receive(:rand) { 26 }
          expect(TDSCombat.stopped_by_cover?(2, @combatant)).to be false
          allow(TDSCombat).to receive(:rand) { 24 }
          expect(TDSCombat.stopped_by_cover?(2, @combatant)).to be true
        end
      end
      
      describe :hit_mount? do
        before do 
          @combatant = double
          @target = double
          allow(@combatant).to receive(:log)
        end
        
        it "should not hit mount if there's no mount" do
          allow(@target).to receive(:mount_type) { nil }
          expect(TDSCombat).to_not receive(:rand) { 0 }
          expect(TDSCombat.hit_mount?(@combatant, @target, 0, false)).to be false
        end
        
        it "should have 0% for a good attack roll" do
          allow(@target).to receive(:mount_type) { "Horse" }
          allow(TDSCombat).to receive(:rand) { 1 }
          expect(TDSCombat.hit_mount?(@combatant, @target, 3, false)).to be false
        end
        
        it "should have 0% if they missed completely" do
          allow(@target).to receive(:mount_type) { "Horse" }
          allow(@combatant).to receive(:mount_type) { nil }
          allow(TDSCombat).to receive(:rand) { 1 }
          expect(TDSCombat.hit_mount?(@combatant, @target, -1, false)).to be false
        end
        
        it "should have 20% when attacker mounted" do
          allow(@target).to receive(:mount_type) { "Horse" }
          allow(@combatant).to receive(:mount_type) { "Horse" }
          allow(TDSCombat).to receive(:rand) { 19 }
          expect(TDSCombat.hit_mount?(@combatant, @target, 0, false)).to be true
          allow(TDSCombat).to receive(:rand) { 21 }
          expect(TDSCombat.hit_mount?(@combatant, @target, 0, false)).to be false
        end        
        
        it "should have 40% when attacker dismounted" do
          allow(@target).to receive(:mount_type) { "Horse" }
          allow(@combatant).to receive(:mount_type) { nil }
          allow(TDSCombat).to receive(:rand) { 39 }
          expect(TDSCombat.hit_mount?(@combatant, @target, 0, false)).to be true
          allow(TDSCombat).to receive(:rand) { 41 }
          expect(TDSCombat.hit_mount?(@combatant, @target, 0, false)).to be false
        end
        
        it "should have 90% when mount hit on purpose" do
          allow(@target).to receive(:mount_type) { "Horse" }
          allow(TDSCombat).to receive(:rand) { 89 }
          expect(TDSCombat.hit_mount?(@combatant, @target, 3, true)).to be true
          allow(TDSCombat).to receive(:rand) { 91 }
          expect(TDSCombat.hit_mount?(@combatant, @target, 3, true)).to be false          
        end
        
      end
      
      
      describe :determine_damage do
        before do 
          @combatant = double
          allow(@combatant).to receive(:log)
          allow(@combatant).to receive(:damage_lethality_mod) { 0 }
          allow(@combatant).to receive(:is_npc?) { false }
          allow(TDSCombat).to receive(:hitloc_severity).with(@combatant, "Chest", false) { "Vital" }
          allow(TDSCombat).to receive(:weapon_stat).with("Knife", "lethality") { 0 }
          allow(TDSCombat).to receive(:rand) { 0 }
          allow(Global).to receive(:read_config).with("tdscombat", "damage_table") { { "GRAZE" => 20, "FLESH" => 60, "IMPAIR" => 100 } }
          
        end
  
        describe "random damage" do
          it "should roll a graze" do
            allow(TDSCombat).to receive(:rand) { 19 }
            expect(TDSCombat.determine_damage(@combatant, "Chest", "Knife")).to eq "GRAZE"
          end
          
          it "should roll a flesh wound" do
            allow(TDSCombat).to receive(:rand) { 59 }
            expect(TDSCombat.determine_damage(@combatant, "Chest", "Knife")).to eq "FLESH"
          end
          
          it "should roll an impairing wound" do
            allow(TDSCombat).to receive(:rand) { 80 }
            expect(TDSCombat.determine_damage(@combatant, "Chest", "Knife")).to eq "IMPAIR"
          end
          
          it "should roll an incap wound" do
            allow(TDSCombat).to receive(:rand) { 101 }
            expect(TDSCombat.determine_damage(@combatant, "Chest", "Knife")).to eq "INCAP"
          end
        end
  
        it "should pass along a crew hit" do
          allow(TDSCombat).to receive(:hitloc_severity).with(@combatant, "Chest", true) { "Normal" }
          expect(TDSCombat.determine_damage(@combatant, "Chest", "Knife", 0, true)).to eq "GRAZE"
        end
        
        it "should account for lethality" do
          allow(TDSCombat).to receive(:weapon_stat).with("Knife", "lethality") { 40 }
          expect(TDSCombat.determine_damage(@combatant, "Chest", "Knife")).to eq "FLESH"
        end

        it "should account for hitloc severity for non-vital" do
          allow(TDSCombat).to receive(:rand) { 29 }
          allow(TDSCombat).to receive(:hitloc_severity).with(@combatant, "Chest", false) { "Normal" }
          expect(TDSCombat.determine_damage(@combatant, "Chest", "Knife")).to eq "GRAZE"
        end

        it "should account for hitloc severity for critical" do
          allow(TDSCombat).to receive(:hitloc_severity).with(@combatant, "Chest", false) { "Critical" }
          allow(TDSCombat).to receive(:rand) { 80 }
          allow(TDSCombat).to receive(:weapon_stat).with("Knife", "lethality") { 0 }
          expect(TDSCombat.determine_damage(@combatant, "Chest", "Knife")).to eq "INCAP"
        end
  
        it "should account for armor" do
          allow(TDSCombat).to receive(:rand) { 24 }
          expect(TDSCombat.determine_damage(@combatant, "Chest", "Knife", -5)).to eq "GRAZE"
        end
      end
      
      describe :determine_armor do
        before do 
          @combatant = double
          allow(@combatant).to receive(:log)
          allow(@combatant).to receive(:vehicle) { nil }
          allow(@combatant).to receive(:armor) { "Tactical" }
          allow(FS3Skills).to receive(:one_shot_die_roll) { { successes: 0 } }
          allow(TDSCombat).to receive(:weapon_stat) { 5 }
        end

        it "should return no protection if no armor" do
          allow(@combatant).to receive(:armor) { nil }
          expect(TDSCombat.determine_armor(@combatant, "Head", "Rifle", 0)).to eq 0
        end
        
        it "should get protection from vehicle armor if in a vehicle" do
          vehicle = double
          allow(vehicle).to receive(:armor) { "Viper" }
          allow(@combatant).to receive(:vehicle) { vehicle }
          
          expect(TDSCombat).to receive(:armor_stat).with("Viper", "protection") { {} }
          TDSCombat.determine_armor(@combatant, "Head", "Rifle", 0)
        end

        it "should get protection from combatant armor if not in a vehicle" do
          expect(TDSCombat).to receive(:armor_stat).with("Tactical", "protection") { {} }
          TDSCombat.determine_armor(@combatant, "Head", "Rifle", 0)
        end
        
        it "should get protection from combatant armor if in a vehicle and crew hit" do
          expect(TDSCombat).to receive(:armor_stat).with("Tactical", "protection") { {} }
          TDSCombat.determine_armor(@combatant, "Head", "Rifle", 0)
        end
        
        it "should bypass armor if not a protected location" do
          allow(TDSCombat).to receive(:armor_stat).with("Tactical", "protection") { { "Chest" => 2 } }
          expect(TDSCombat.determine_armor(@combatant, "Head", "Rifle", 0)).to eq 0
        end
        
        it "should bypass armor if weapon wins by enough" do
          allow(TDSCombat).to receive(:rand).with(8) { 6 }
          allow(TDSCombat).to receive(:weapon_stat).with("Rifle", "penetration") { 5 }
          allow(TDSCombat).to receive(:armor_stat).with("Tactical", "protection") { { "Head" => 3 } }
          expect(TDSCombat.determine_armor(@combatant, "Head", "Rifle", 0)).to eq 0
        end
        
        it "should provide minimum armor" do
          allow(TDSCombat).to receive(:rand).with(8) { 4 }
          allow(TDSCombat).to receive(:rand).with(25) { 24 }
          allow(TDSCombat).to receive(:weapon_stat).with("Rifle", "penetration") { 5 }
          allow(TDSCombat).to receive(:armor_stat).with("Tactical", "protection") { { "Head" => 3 } }
          expect(TDSCombat.determine_armor(@combatant, "Head", "Rifle", 0)).to eq 24
        end

        it "should provide some armor" do
          allow(TDSCombat).to receive(:rand).with(8) { 2 }
          allow(TDSCombat).to receive(:weapon_stat).with("Rifle", "penetration") { 5 }
          allow(TDSCombat).to receive(:armor_stat).with("Tactical", "protection") { { "Head" => 3 } }
          allow(TDSCombat).to receive(:rand).with(25) { 19 }
          expect(TDSCombat.determine_armor(@combatant, "Head", "Rifle", 0)).to eq 44
        end

        it "should provide extra armor" do
          allow(TDSCombat).to receive(:rand).with(8) { 0 }
          allow(TDSCombat).to receive(:weapon_stat).with("Rifle", "penetration") { 5 }
          allow(TDSCombat).to receive(:armor_stat).with("Tactical", "protection") { { "Head" => 3 } }
          allow(TDSCombat).to receive(:rand).with(50) { 15 }
          expect(TDSCombat.determine_armor(@combatant, "Head", "Rifle", 0)).to eq 65
        end

        it "should stop attack if armor wins by enough" do
          allow(TDSCombat).to receive(:rand).with(8) { 1 }
          allow(TDSCombat).to receive(:weapon_stat).with("Rifle", "penetration") { 5 }
          allow(TDSCombat).to receive(:armor_stat).with("Tactical", "protection") { { "Head" => 6 } }
          expect(TDSCombat.determine_armor(@combatant, "Head", "Rifle", 0)).to eq 100
        end

        it "should add in attacker successes for to pen roll" do
          allow(TDSCombat).to receive(:rand).with(8) { 8 }
          allow(TDSCombat).to receive(:weapon_stat).with("Rifle", "penetration") { 3 }
          allow(TDSCombat).to receive(:armor_stat).with("Tactical", "protection") { { "Head" => 5 } }
          expect(TDSCombat.determine_armor(@combatant, "Head", "Rifle", 2)).to eq 0
        end        
      end
      
      describe :determine_attack_margin do
        before do
          @combatant = double
          allow(@combatant).to receive(:log)
          @target = double
          
          allow(@combatant).to receive(:name) { "A" }
          allow(@target).to receive(:name) { "D" }
          
          allow(@combatant).to receive(:recoil) { 0 }
          allow(@combatant).to receive(:weapon) { "Rifle" }
          allow(@target).to receive(:stance) { "Normal" }
          
          allow(TDSCombat).to receive(:hit_mount?) { false }
        end
        
        it "should roll attack and defense" do
          expect(TDSCombat).to receive(:roll_attack).with(@combatant, @target, 0) { 0 }
          expect(TDSCombat).to receive(:roll_defense).with(@target, "Rifle") { 0 }
          TDSCombat.determine_attack_margin(@combatant, @target, 0)
        end
        
        it "should add in an attacker modifier" do
          expect(TDSCombat).to receive(:roll_attack).with(@combatant, @target, 1) { 0 }
          expect(TDSCombat).to receive(:roll_defense).with(@target, "Rifle") { 0 }
          TDSCombat.determine_attack_margin(@combatant, @target, 1)
        end
        
        it "should subtract recoil" do
          allow(@combatant).to receive(:recoil) { 2 }
          expect(TDSCombat).to receive(:roll_attack).with(@combatant, @target, -2) { 0 }
          expect(TDSCombat).to receive(:roll_defense).with(@target, "Rifle") { 0 }
          TDSCombat.determine_attack_margin(@combatant, @target, 0)
        end
        
        it "should be a dodge if the defender wins when attacked by melee" do
          allow(@combatant).to receive(:weapon) { "Knife" }
          allow(TDSCombat).to receive(:weapon_stat).with("Knife", "weapon_type") { "Melee" }
          allow(TDSCombat).to receive(:roll_attack) { 1 }
          allow(TDSCombat).to receive(:roll_defense) { 2 }
          result = TDSCombat.determine_attack_margin(@combatant, @target, 0)
          expect(result[:message]).to eq "tdscombat.attack_dodged"
          expect(result[:hit]).to eq false
        end
        
        it "should be a dodge easily if defender wins by a lot vs melee" do
          allow(TDSCombat).to receive(:weapon_stat).with("Rifle", "weapon_type") { "Ranged" }
          allow(TDSCombat).to receive(:roll_attack) { 1 }
          allow(TDSCombat).to receive(:roll_defense) { 4 }
          allow(@target).to receive(:is_in_vehicle?) { true }
          result = TDSCombat.determine_attack_margin(@combatant, @target, 0)
          expect(result[:message]).to eq "tdscombat.attack_dodged_easily"
          expect(result[:hit]).to eq false
        end
        
        it "should be a dodge if the defender wins when in vehicle" do
          allow(TDSCombat).to receive(:weapon_stat).with("Rifle", "weapon_type") { "Ranged" }
          allow(TDSCombat).to receive(:roll_attack) { 1 }
          allow(TDSCombat).to receive(:roll_defense) { 2 }
          allow(@target).to receive(:is_in_vehicle?) { true }
          result = TDSCombat.determine_attack_margin(@combatant, @target, 0)
          expect(result[:message]).to eq "tdscombat.attack_dodged"
          expect(result[:hit]).to eq false
        end
        
        it "should be a near miss if defender wins vs ranged" do
          allow(TDSCombat).to receive(:weapon_stat).with("Rifle", "weapon_type") { "Ranged" }
          allow(TDSCombat).to receive(:roll_attack) { 1 }
          allow(TDSCombat).to receive(:roll_defense) { 2 }
          allow(@target).to receive(:is_in_vehicle?) { false }
          result = TDSCombat.determine_attack_margin(@combatant, @target, 0)
          expect(result[:message]).to eq "tdscombat.attack_near_miss"
          expect(result[:hit]).to eq false
        end
        
        it "should hit cover if defender is in cover and cover applies" do
          allow(@target).to receive(:stance) { "Cover" }
          expect(TDSCombat).to receive(:stopped_by_cover?).with(2, @combatant) { true }
          allow(TDSCombat).to receive(:roll_attack) { 3 }
          allow(TDSCombat).to receive(:roll_defense) { 1 }
          result = TDSCombat.determine_attack_margin(@combatant, @target, 0)
          expect(result[:message]).to eq "tdscombat.attack_hits_cover"
          expect(result[:hit]).to eq false
        end

        it "should be hit if the attacker ties" do
          allow(TDSCombat).to receive(:roll_attack) { 2 }
          allow(TDSCombat).to receive(:roll_defense) { 2 }
          result = TDSCombat.determine_attack_margin(@combatant, @target, 0)
          expect(result[:message]).to be_nil
          expect(result[:attacker_net_successes]).to eq 0
          expect(result[:hit]).to eq true
        end
        
        it "should have a chance to hit mount" do
          expect(TDSCombat).to receive(:hit_mount?).with(@combatant, @target, 1, false) { true }
          expect(TDSCombat).to receive(:resolve_mount_ko).with(@target) { false }
          allow(TDSCombat).to receive(:roll_attack) { 3 }
          allow(TDSCombat).to receive(:roll_defense) { 2 }
          result = TDSCombat.determine_attack_margin(@combatant, @target, 0)
          expect(result[:message]).to eq "tdscombat.attack_hits_mount"
          expect(result[:hit]).to eq false
        end
        
        it "should ko mount if hit badly" do
          expect(TDSCombat).to receive(:hit_mount?).with(@combatant, @target, 1, false) { true }
          expect(TDSCombat).to receive(:resolve_mount_ko).with(@target) { true }
          allow(TDSCombat).to receive(:roll_attack) { 3 }
          allow(TDSCombat).to receive(:roll_defense) { 2 }
          expect(@target).to receive(:inflict_damage).with("IMPAIR", "Fall Damage", true, false)
          expect(@target).to receive(:update).with(:mount_type => nil)
          result = TDSCombat.determine_attack_margin(@combatant, @target, 0)
          expect(result[:message]).to eq "tdscombat.attack_hits_mount"
          expect(result[:hit]).to eq false
        end
        
        it "should be a near miss if attacker doesn't get enough success for called shot" do
          allow(TDSCombat).to receive(:weapon_stat).with("Rifle", "weapon_type") { "Ranged" }
          allow(TDSCombat).to receive(:roll_attack) { 2 }
          allow(TDSCombat).to receive(:roll_defense) { 1 }
          allow(@target).to receive(:is_in_vehicle?) { false }
          result = TDSCombat.determine_attack_margin(@combatant, @target, 0, "Head")
          expect(result[:message]).to eq "tdscombat.attack_near_miss"
          expect(result[:hit]).to eq false
        end
        
        it "should be a clean if called shot but attacker missed" do
          allow(TDSCombat).to receive(:weapon_stat).with("Rifle", "weapon_type") { "Melee" }
          allow(TDSCombat).to receive(:roll_attack) { 2 }
          allow(TDSCombat).to receive(:roll_defense) { 3 }
          allow(@target).to receive(:is_in_vehicle?) { false }
          result = TDSCombat.determine_attack_margin(@combatant, @target, 0, "Head")
          expect(result[:message]).to eq "tdscombat.attack_dodged"
          expect(result[:hit]).to eq false
        end

        it "should be hit if the attacker wins" do
          allow(TDSCombat).to receive(:roll_attack) { 4 }
          allow(TDSCombat).to receive(:roll_defense) { 2 }
          result = TDSCombat.determine_attack_margin(@combatant, @target, 0)
          expect(result[:message]).to be_nil
          expect(result[:attacker_net_successes]).to eq 2
          expect(result[:hit]).to eq true
        end
      end
      
      describe :attack_target do
        before do
          @target = double
          @combatant = double
          allow(@combatant).to receive(:log)
          allow(@combatant).to receive(:weapon) { "Knife" }
          allow(TDSCombat).to receive(:weapon_stat).with("Knife", "recoil") { 1 }
          allow(@combatant).to receive(:recoil) { 0 }
          allow(@combatant).to receive(:update)
          allow(@target).to receive(:riding_in) { nil }
          allow(@combatant).to receive(:name) { "A" }
          allow(TDSCombat).to receive(:determine_attack_margin) { { hit: true, attacker_net_successes: 2 }}
          allow(TDSCombat).to receive(:resolve_attack)
        end
        
        it "should return margin message if a miss" do
          expect(TDSCombat).to receive(:determine_attack_margin).with(@combatant, @target, 0, nil, false) { { hit: false, message: "dodged" }}
          expect(TDSCombat.attack_target(@combatant, @target)).to eq ["dodged"]
        end
        
        it "should pass along the attack mod" do
          expect(TDSCombat).to receive(:determine_attack_margin).with(@combatant, @target, -1, nil, false) { { hit: false, message: "dodged" }}
          TDSCombat.attack_target(@combatant, @target, -1)
        end
        
        it "should update recoil" do
          allow(@combatant).to receive(:recoil) { 5 }
          expect(@combatant).to receive(:update).with(recoil: 6)
          TDSCombat.attack_target(@combatant, @target)
        end
        
        it "should resolve the attack" do
          expect(TDSCombat).to receive(:resolve_attack).with(@combatant, "A", @target, "Knife", 2, nil, false)
          TDSCombat.attack_target(@combatant, @target)
        end
        
        it "should resolve the attack with a called shot and mod" do
          expect(TDSCombat).to receive(:resolve_attack).with(@combatant, "A", @target, "Knife", 2, "Head", false)
          TDSCombat.attack_target(@combatant, @target, 3, "Head")
        end
        
        it "should resolve the attack with a crew hit" do
          expect(TDSCombat).to receive(:resolve_attack).with(@combatant, "A", @target, "Knife", 2, nil, true)
          TDSCombat.attack_target(@combatant, @target, 3, nil, true)
        end
        
        it "should attack the pilot when the passenger is targeted" do
          pilot = double
          vehicle = double
          allow(@target).to receive(:riding_in) { vehicle }
          allow(vehicle).to receive(:pilot) { pilot }
          expect(TDSCombat).to receive(:resolve_attack).with(@combatant, "A", pilot, "Knife", 2, nil, false)
          TDSCombat.attack_target(@combatant, @target)
        end

        it "should not attack a non-existent pilot if a passenger is targeted" do
          pilot = double
          vehicle = double
          allow(@target).to receive(:riding_in) { vehicle }
          allow(vehicle).to receive(:pilot) { nil }
          expect(TDSCombat).to receive(:resolve_attack).with(@combatant, "A", @target, "Knife", 2, nil, false)
          TDSCombat.attack_target(@combatant, @target)
        end
      end
      
      
      describe :resolve_attack do    
        
        before do
          @target = double
          @combatant = double
          allow(TDSCombat).to receive(:determine_armor) { 0 }
          allow(TDSCombat).to receive(:determine_damage) { "GRAZE" }
          allow(TDSCombat).to receive(:weapon_is_stun?) { false }
          allow(TDSCombat).to receive(:determine_hitloc) { "Chest" }
          allow(TDSCombat).to receive(:resolve_possible_crew_hit) { [] }
          allow(TDSCombat).to receive(:weapon_stat) { "x" }
          allow(@target).to receive(:log)
          allow(@target).to receive(:inflict_damage)
          allow(@target).to receive(:name) { "D" }
          allow(@target).to receive(:add_stress)
          allow(@target).to receive(:update).with(freshly_damaged: true)
          allow(@target).to receive(:damaged_by) { [] }
          allow(@target).to receive(:luck) { "" }
          allow(@target).to receive(:update).with(damaged_by: [ "A" ]) {}
          allow(@combatant).to receive(:luck) { "" }
          allow(TDSCombat).to receive(:award_hit_achievement) {}
        end
            
        
        it "should determine hit location if no called shot" do
          expect(TDSCombat).to receive(:determine_hitloc).with(@target, 0, nil, false) { "Head" }
          TDSCombat.resolve_attack(@combatant, "A", @target, "Knife")
        end

        it "should determine hit location if called shot" do
          expect(TDSCombat).to receive(:determine_hitloc).with(@target, 0, "Arm", false) { "Hand" }
          TDSCombat.resolve_attack(@combatant, "A", @target, "Knife", 0, "Arm")
        end
        
        it "should return armor message if stopped by armor" do
          expect(TDSCombat).to receive(:determine_armor).with(@target, "Chest", "Knife", 2, false) { 110 }
          expect(TDSCombat.resolve_attack(@combatant, "A", @target, "Knife", 2)).to eq ["tdscombat.attack_stopped_by_armor"]
        end
        
        it "should reduce damage if armor slowed the attack" do
          allow(TDSCombat).to receive(:determine_armor) { 22 }
          expect(TDSCombat).to receive(:determine_damage).with(@target, "Chest", "Knife", -22, false) { "INCAP" }
          TDSCombat.resolve_attack(@combatant, "A", @target, "Knife")
        end
        
        it "should update damaged by" do 
          allow(@target).to receive(:damaged_by) { [ "X" ] }
          expect(@target).to receive(:update).with(damaged_by: [ "X", "A" ])
          expect(TDSCombat).to receive(:determine_damage).with(@target, "Chest", "Knife", 0, false) { "INCAP" }
          TDSCombat.resolve_attack(@combatant, "A", @target, "Knife")
        end
        
        it "should add success to damage" do
          expect(TDSCombat).to receive(:determine_damage).with(@target, "Chest", "Knife", 15, false) { "INCAP" }
          TDSCombat.resolve_attack(@combatant, "A", @target, "Knife", 4)
        end
        
        it "should add strength to damage if using a melee weapon" do
          allow(TDSCombat).to receive(:weapon_stat).with("Knife", "weapon_type") { "Melee" }
          allow(TDSCombat).to receive(:roll_strength).with(@combatant) { 3 }          
          expect(TDSCombat).to receive(:determine_damage).with(@target, "Chest", "Knife", 10, false) { "INCAP" }
          TDSCombat.resolve_attack(@combatant, "A", @target, "Knife")
        end
        
        
        it "should add luck to damage if luck spent on attack" do
          allow(TDSCombat).to receive(:determine_armor) { 22 }
          allow(@combatant).to receive(:luck) { "Attack" }
          expect(TDSCombat).to receive(:determine_damage).with(@target, "Chest", "Knife", 8, false) { "INCAP" }
          TDSCombat.resolve_attack(@combatant, "A", @target, "Knife")
        end
        
        it "should subtract luck from damage if luck spent on defense" do
          allow(TDSCombat).to receive(:determine_armor) { 22 }
          allow(@target).to receive(:luck) { "Defense" }
          expect(TDSCombat).to receive(:determine_damage).with(@target, "Chest", "Knife", -52, false) { "INCAP" }
          TDSCombat.resolve_attack(@combatant, "A", @target, "Knife")
        end
        
        it "should inflict damage" do
          expect(@target).to receive(:inflict_damage).with("GRAZE", "Knife - Chest", false, false)
          TDSCombat.resolve_attack(@combatant, "A", @target, "Knife")
        end      
        
        it "should mark as freshly damaged" do
          allow(TDSCombat).to receive(:determine_damage) { "FLESH" }
          expect(@target).to receive(:update).with(freshly_damaged: true)
          TDSCombat.resolve_attack(@combatant, "A", @target, "Knife")
        end
        
        it "should not mark as freshly damaged for a graze wound" do
          allow(TDSCombat).to receive(:determine_damage) { "GRAZE" }
          expect(@target).to_not receive(:update).with(freshly_damaged: true)
          TDSCombat.resolve_attack(@combatant, "A", @target, "Knife")
        end

        it "should return a hit message" do
          expect(TDSCombat.resolve_attack(@combatant, "A", @target, "Knife")).to eq ["tdscombat.attack_hits"]
        end
        
        it "should add a stress point" do
          expect(@target).to receive(:add_stress).with(1)
          expect(TDSCombat.resolve_attack(@combatant, "A", @target, "Knife")).to eq ["tdscombat.attack_hits"]
        end
        
        it "should pass along a crew hit" do
          expect(@target).to receive(:inflict_damage).with("GRAZE", "Knife - Chest", false, true)
          expect(TDSCombat.resolve_attack(@combatant, "A", @target, "Knife", 0, nil, true)).to eq ["tdscombat.attack_hits"]
        end
      end
      
      describe :resolve_possible_crew_hit do
        before do
          @target = double
          allow(@target).to receive(:is_in_vehicle?) { true }
          allow(@target).to receive(:log)
          @vehicle = double
          allow(TDSCombat).to receive(:hitloc_chart).with(@target) { { "crew_areas" => ["Cockpit"] } }
          
          # By seeding the kernel random number generator, the first two shrapnel rolls
          # will always be 2, 1.
          Kernel.srand 5
          
        end
        
        it "should return nothing if not in vehicle" do
          allow(@target).to receive(:is_in_vehicle?) { false }
          expect(TDSCombat.resolve_possible_crew_hit(@target, "Body", "GRAZE")).to eq []
        end
        
        it "should not do damage if not a crew hitloc" do
          allow(@target).to receive(:vehicle) { @vehicle}
          expect(TDSCombat.resolve_possible_crew_hit(@target, "Body", "GRAZE")).to eq []
        end
        
        it "should inflict shrapnel to each passenger" do
          p1 = double
          p2 = double
          allow(p1).to receive(:name) { "a" }
          allow(p2).to receive(:name) { "b" }
          
          
          allow(@target).to receive(:vehicle) { @vehicle }
          allow(@vehicle).to receive(:passengers) { [p1] }
          allow(@vehicle).to receive(:pilot) { p2 }
          expect(TDSCombat).to receive(:resolve_attack).with(nil, t('tdscombat.crew_hit'), p1, "Shrapnel", 0, nil, true) { ["a1"]}
          expect(TDSCombat).to receive(:resolve_attack).with(nil, t('tdscombat.crew_hit'), p1, "Shrapnel", 0, nil, true) { ["a2"]}
          expect(TDSCombat).to receive(:resolve_attack).with(nil, t('tdscombat.crew_hit'), p2, "Shrapnel", 0, nil, true) { ["a3"]}

          expect(TDSCombat.resolve_possible_crew_hit(@target, "Cockpit", "IMPAIR")).to eq ["a1", "a2", "a3"]
        end
        
      end
      
      describe :resolve_mount_ko do
        before do
          @target = double
          allow(@target).to receive(:mount_type) { "Horse" }
          allow(@target).to receive(:log)
        end
        
        it "should factor in mount toughness" do
          allow(TDSCombat).to receive(:mount_stat).with("Horse", "toughness") { 2 }
          expect(FS3Skills).to receive(:one_shot_die_roll).with(2) { { successes: 0 } }
          TDSCombat.resolve_mount_ko(@target)
        end
        
        it "should be KOed with a bad roll" do
          allow(TDSCombat).to receive(:mount_stat).with("Horse", "toughness") { 2 }
          expect(FS3Skills).to receive(:one_shot_die_roll).with(2) { { successes: 0 } }
          expect(TDSCombat.resolve_mount_ko(@target)).to eq true
        end
        
        it "should not be KOed with a good roll" do
          allow(TDSCombat).to receive(:mount_stat).with("Horse", "toughness") { 2 }
          expect(FS3Skills).to receive(:one_shot_die_roll).with(2) { { successes: 3 } }
          expect(TDSCombat.resolve_mount_ko(@target)).to eq false
        end
        
      end
    end
    
    
    describe :resolve_explosion do
      before do
        @combatant = double
        @target = double
        allow(@combatant).to receive(:name) { "Bob" }
        allow(@combatant).to receive(:weapon) { "Grenade" }
        allow(TDSCombat).to receive(:rand) { 0 }
      end
      
      it "should resolve attack if hit" do
        expect(TDSCombat).to receive(:determine_attack_margin).with(@combatant, @target) { { margin: 1, hit: true, attacker_net_successes: 3 }}
        expect(TDSCombat).to receive(:resolve_attack).with(@combatant, "Bob", @target, "Grenade", 3) { [ 'result' ]}
        expect(TDSCombat.resolve_explosion(@combatant, @target)).to eq [ 'result' ]
      end
      
      it "should not resolve attack if miss" do
        expect(TDSCombat).to receive(:determine_attack_margin).with(@combatant, @target) { { margin: 0, hit: false, message: "Missed!" }}
        expect(TDSCombat).to_not receive(:resolve_attack)
        expect(TDSCombat.resolve_explosion(@combatant, @target)).to eq [ 'Missed!' ]
      end
      
      it "should allow max shrapnel if multiple succ" do
        expect(TDSCombat).to receive(:weapon_stat).with("Grenade", "has_shrapnel") { true }
        expect(TDSCombat).to receive(:determine_attack_margin).with(@combatant, @target) { { margin: 1, hit: true, attacker_net_successes: 3 }}
        expect(TDSCombat).to receive(:rand).with(5) { 2 }        
        expect(TDSCombat).to receive(:resolve_attack).with(@combatant, "Bob", @target, "Grenade", 3) { [ 'result1' ]}
        expect(TDSCombat).to receive(:resolve_attack).with(nil, "Bob", @target, "Shrapnel") { [ 'result2' ]}
        expect(TDSCombat).to receive(:resolve_attack).with(nil, "Bob", @target, "Shrapnel") { [ 'result3' ]}
        expect(TDSCombat.resolve_explosion(@combatant, @target)).to eq [ 'result1', 'result2', 'result3' ]
      end
      
      it "should allow min shrapnel if missed" do
        expect(TDSCombat).to receive(:weapon_stat).with("Grenade", "has_shrapnel") { true }
        expect(TDSCombat).to receive(:determine_attack_margin).with(@combatant, @target) { { margin: 0, hit: false, message: "Missed!" }}
        expect(TDSCombat).to receive(:rand).with(2) { 1 }        
        expect(TDSCombat).to receive(:resolve_attack).with(nil, "Bob", @target, "Shrapnel") { [ 'result2' ]}
        expect(TDSCombat.resolve_explosion(@combatant, @target)).to eq [ 'Missed!', 'result2' ]
      end
      
      it "should have no shrapnel if weapon doesn't allow it" do
        expect(TDSCombat).to receive(:weapon_stat).with("Grenade", "has_shrapnel") { false }
        expect(TDSCombat).to receive(:determine_attack_margin).with(@combatant, @target) { { margin: 0, hit: false, message: "Missed!" }}
        expect(TDSCombat).to_not receive(:rand)
        expect(TDSCombat.resolve_explosion(@combatant, @target)).to eq [ 'Missed!' ]
      end
      
    end
  end
end
