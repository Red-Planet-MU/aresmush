module AresMUSH
  module TDSCombat
    describe TDSCombat do
      before do
        @combat = double
        @enactor = double
        @client = double
        @combatant = double
        
        allow(@combatant).to receive(:name) { "Trooper" }
        
        stub_translate_for_testing
      end

      describe :armor_stat do
        before do 
          specials = {
            "Helmet" => { "defense" => 2, "protection" => { "Head" => 2 } },
            "Cup" => { "protection" => { "Groin" => 2 } },
            "Defenseless" => { "protection" => { "Chest" => 2 } }  
          }
          armor = { "defense" => 1, "protection" => { "Head" => 1, "Body" => 4 } }
          allow(TDSCombat).to receive(:armor_specials) { specials }
          allow(TDSCombat).to receive(:armor).with("Military") { armor }
        end
        
        it "should return nil if armor not found" do
          allow(TDSCombat).to receive(:armor).with("Police") { nil }
          expect(TDSCombat.armor_stat("Police", "protection")).to be_nil
        end
        
        it "should return nil if no stat" do
          expect(TDSCombat.armor_stat("Military", "foo")).to be_nil
        end
        
        it "should add special protection together" do
          protection = TDSCombat.armor_stat("Military+Helmet+Cup", "protection")
          expect(protection['Head']).to eq 3
          expect(protection['Body']).to eq 4
          expect(protection['Groin']).to eq 2
        end
        
        it "should not affect the underlying protection values in the config" do
          protection = TDSCombat.armor_stat("Military+Helmet+Cup", "protection")
          expect(protection['Head']).to eq 3
          protection = TDSCombat.armor_stat("Military", "protection")
          expect(protection['Head']).to eq 1
        end
        
        it "should add other stats" do
          defense = TDSCombat.armor_stat("Military+Helmet", "defense")
          expect(defense).to eq 3
        end
        
        it "should not add anything if no special stat exists" do
          defense = TDSCombat.armor_stat("Military+Cup", "defense")
          expect(defense).to eq 1
        end
        
        
      end      
      
      describe :weapon_stat do
        before do
          allow(TDSCombat).to receive(:weapon).with("Rifle") { { "penetration" => 3, "lethality" => 10 } }
          specials = {
            "Ap" => { "penetration" => 2 },
            "Silencer" => { "lethality" => -5 }
          }
          allow(TDSCombat).to receive(:weapon_specials) { specials }
        end
        
        it "should return nil if weapon not found" do
           allow(TDSCombat).to receive(:weapon) { nil }
           expect(TDSCombat.weapon_stat("Banjo", "penetration")).to be_nil
        end

        it "should return nil if weapon has no stat" do
           expect(TDSCombat.weapon_stat("Rifle", "moxie")).to be_nil
        end
        
        it "should return a value for a weapon without a special" do
          expect(TDSCombat.weapon_stat("Rifle", "penetration")).to eq 3
        end

        it "should return raw value for a weapon with an invalid special" do
          expect(TDSCombat.weapon_stat("Rifle+Foo", "penetration")).to eq 3
        end
        
        it "should adjust a value for a weapon with a special" do
          expect(TDSCombat.weapon_stat("Rifle+Ap", "penetration")).to eq 5
        end
        
        it "should handle multiple specials" do
          expect(TDSCombat.weapon_stat("Rifle+Ap+Silencer", "penetration")).to eq 5
        end
      end
      
      describe :set_default_gear do
        before do
          allow(TDSCombat).to receive(:combatant_type_stat) { nil }
          allow(TDSCombat).to receive(:combatant_type_stat) { nil }
        end
        
        it "should set a weapon if set" do
          expect(TDSCombat).to receive(:combatant_type_stat).with("soldier", "weapon") { "rifle" }
          expect(TDSCombat).to receive(:combatant_type_stat).with("soldier", "weapon_specials") { "specials" }
          expect(TDSCombat).to receive(:set_weapon).with(@enactor, @combatant, "rifle", "specials")
          TDSCombat.set_default_gear(@enactor, @combatant, "soldier")
        end
        
        it "should not set a weapon if none set" do
          expect(TDSCombat).to_not receive(:set_weapon)
          TDSCombat.set_default_gear(@enactor, @combatant, "soldier")
        end

        it "should set armor if set" do
          expect(TDSCombat).to receive(:combatant_type_stat).with("soldier", "armor") { "kevlar" }
          expect(TDSCombat).to receive(:combatant_type_stat).with("soldier", "armor_specials") { "specials" }
          expect(TDSCombat).to receive(:set_armor).with(@enactor, @combatant, "kevlar", "specials")
          TDSCombat.set_default_gear(@enactor, @combatant, "soldier")
        end
        
        it "should not set armor if none set" do
          expect(TDSCombat).to_not receive(:set_armor)
          TDSCombat.set_default_gear(@enactor, @combatant, "soldier")
        end

      end
      
      describe :set_weapon do
        before do
          allow(@combatant).to receive(:combat) { @combat }
          allow(TDSCombat).to receive(:emit_to_combat) {}
          allow(TDSCombat).to receive(:npcmaster_text) { "npcmaster" }
          allow(@combatant).to receive(:update)
          allow(TDSCombat).to receive(:weapon_stat)
          allow(@combatant).to receive(:action=)
          allow(@combatant).to receive(:weapon)
          allow(@combatant).to receive(:weapon_specials)
          allow(@combatant).to receive(:prior_ammo) { nil }
          allow(@combatant).to receive(:weapon_name) { nil }
        end

        it "should pretty up the weapon and specials if set" do
          expect(@combatant).to receive(:update).with(weapon_name: "Rifle")
          expect(@combatant).to receive(:update).with(weapon_specials: ["S1", "S2"])
          TDSCombat.set_weapon(@enactor, @combatant, "rifle", [ "s1", "s2" ])
        end
        
        it "should reset ammo" do
          expect(TDSCombat).to receive(:weapon_stat).with("Rifle+S1+S2", "ammo") { 22 }
          expect(@combatant).to receive(:update).with(ammo: 22)
          TDSCombat.set_weapon(@enactor, @combatant, "rifle", [ "s1", "s2" ])
        end
        
        it "should reset stats if nil" do
          expect(@combatant).to receive(:update).with(weapon_name: "Unarmed")
          expect(@combatant).to receive(:update).with(weapon_specials: [])
          expect(@combatant).to receive(:update).with(ammo: 0)
          expect(@combatant).to receive(:update).with(max_ammo: 0)
          TDSCombat.set_weapon(@enactor, @combatant, nil, nil)
        end
        
        it "should reset their combat action" do
          expect(@combatant).to receive(:update).with(action_klass: nil)
          expect(@combatant).to receive(:update).with(action_args: nil)
          TDSCombat.set_weapon(@enactor, @combatant, nil, nil)
        end
        
        it "should emit to combat" do
          expect(TDSCombat).to receive(:emit_to_combat).with(@combat, "tdscombat.weapon_changed", "npcmaster")
          TDSCombat.set_weapon(@enactor, @combatant, "rifle", [ "s1", "s2" ])
        end
        
        it "should set ammo to previous used ammo if there is one" do
          expect(TDSCombat).to receive(:weapon_stat).with("Rifle", "ammo") { 22 }
          expect(@combatant).to receive(:prior_ammo) { { "Rifle" => 17 } }
          expect(@combatant).to receive(:update).with(ammo: 17)
          TDSCombat.set_weapon(@enactor, @combatant, "rifle", nil)
        end

        it "should set ammo to max ammo if there isn't one" do
          expect(TDSCombat).to receive(:weapon_stat).with("Rifle", "ammo") { 22 }
          expect(@combatant).to receive(:prior_ammo) { { "Pistol" => 7 } }
          expect(@combatant).to receive(:update).with(ammo: 22)
          TDSCombat.set_weapon(@enactor, @combatant, "rifle", nil)
        end
        
        it "should save their prior ammo" do
          expect(TDSCombat).to receive(:weapon_stat).with("Rifle", "ammo") { 22 }
          expect(@combatant).to receive(:weapon_name) { "Pistol" }.twice
          expect(@combatant).to receive(:ammo) { 7 }
          expect(@combatant).to receive(:prior_ammo) { { "KEW" => 77 } }
          expect(@combatant).to receive(:update).with(ammo: 22)
          expect(@combatant).to receive(:update).with(max_ammo: 22)
          expect(@combatant).to receive(:update).with(prior_ammo: { "KEW" => 77, "Pistol" => 7 })
          TDSCombat.set_weapon(@enactor, @combatant, "rifle", nil)
        end
        
      end
    end
  end
end
