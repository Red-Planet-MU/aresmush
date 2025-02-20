module AresMUSH
  module TDSCombat
    class GearDetailRequestHandler
      def handle(request)
        type = request.args[:type]
        name = request.args[:name]

        if (name.blank?)
          return { error: t('tdscombat.invalid_gear_type') }
        end

        case (type || "").downcase
        when "weapon"
          data = TDSCombat.weapon(name)
        when "armor"
          data = TDSCombat.armor(name)
        when "vehicle"
          data = TDSCombat.vehicle(name)
        when "mount"
          data = TDSCombat.mount(name)
        else
          return { error: t('tdscombat.invalid_gear_type') }
        end

        if (!data)
          return { error: t('tdscombat.invalid_gear_type') }
        end
        
        values = data.map { |key, value|  {
          title: key.humanize.titleize,
          detail: Website.format_markdown_for_html(TDSCombat.gear_detail(value).to_s)
          }
        }        
        
        specials = GearSpecialInfo.new(data, type).specials.map { |name, effects| {
          title: name,
          effects: effects
        }}
        
        {
          type: type.titleize,
          name: name.titleize,
          values: values,
          specials: specials
        }
      end
    end
  end
end


