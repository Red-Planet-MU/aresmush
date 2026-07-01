module AresMUSH
  module FS3Combat
    class CombatKillCmd
    #kill <name>
      include CommandHandler

      def check_errors
        return nil if FS3Skills.can_manage_abilities?(enactor)
        return t('dispatcher.not_allowed')
      end

      def handle
        target = Character.find_one_by_name(cmd.args)
        FS3Combat.kill(target)
      end

    end
  end
end