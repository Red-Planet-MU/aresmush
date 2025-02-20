module AresMUSH
  module TDSCombat
    class ArmorDetailCmd
      include CommandHandler
      
      attr_accessor :name
      
      def parse_args
        self.name = titlecase_arg(cmd.args)
      end
      
      def required_args
        [ self.name ]
      end
      
      def check_armor_exists
        return t('tdscombat.invalid_armor') if !TDSCombat.armor(self.name)
        return nil
      end
      
      def handle
        template = GearDetailTemplate.new(TDSCombat.armor(self.name), self.name, :armor)
        client.emit template.render
      end
    end
  end
end