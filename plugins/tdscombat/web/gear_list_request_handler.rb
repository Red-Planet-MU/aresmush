module AresMUSH
  module TDSCombat
    class GearListRequestHandler
      def handle(request)
        {
          weapons: build_list(TDSCombat.weapons),
          armor: build_list(TDSCombat.armors),
          vehicles: build_list(TDSCombat.vehicles),
          mounts: build_list(TDSCombat.mounts),
          allow_vehicles: TDSCombat.vehicles_allowed?,
          allow_mounts: TDSCombat.mounts_allowed?
        } 
      end
      
      def build_list(hash)
        hash.sort.map { |name, data| {
          key: name,
          name: name.titleize,
          description: data['description']
          }
        }
      end
    end
  end
end


