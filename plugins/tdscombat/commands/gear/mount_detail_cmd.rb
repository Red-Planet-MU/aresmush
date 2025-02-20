module AresMUSH
  module TDSCombat
    class MountDetailCmd
      include CommandHandler
      
      attr_accessor :name
      
      def parse_args
        self.name = titlecase_arg(cmd.args)
      end

      def required_args
        [ self.name ]
      end
      
      def check_mounts_allowed
        return t('tdscombat.mounts_disabled') if !TDSCombat.mounts_allowed?
        return nil
      end
      
      def check_valid_mount
        return t('tdscombat.invalid_mount') if !TDSCombat.mount(self.name)
        return nil
      end
      
      def handle
        template = GearDetailTemplate.new(TDSCombat.mount(self.name), self.name, :mount)
        client.emit template.render
      end
    end
  end
end