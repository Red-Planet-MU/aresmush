module AresMUSH
  module TDSCombat
    class WeaponDetailCmd
      include CommandHandler
      
      attr_accessor :name
      
      def parse_args
        self.name = titlecase_arg(cmd.args)
      end

      def required_args
        [ self.name ]
      end
      
      def check_weapon_exists
        return t('tdscombat.invalid_weapon') if !TDSCombat.weapon(self.name)
        return nil
      end
      
      def handle
        template = GearDetailTemplate.new(TDSCombat.weapon(self.name), self.name, :weapon)
        client.emit template.render
      end
    end
  end
end