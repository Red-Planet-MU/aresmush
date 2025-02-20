module AresMUSH
  module TDSCombat
    class CombatLogCmd
      include CommandHandler
      
      attr_accessor :page
         
      def parse_args
        if (!cmd.args)
          self.page = cmd.page
        else
          self.page = cmd.args ? cmd.args.to_i : 1
        end
      end
      
      def handle
        combat = TDSCombat.combat(enactor.name)
        if (!combat)
          client.emit_failure t('tdscombat.you_are_not_in_combat')
          return
        end
        
        if (combat.debug_log)
          list = combat.debug_log.combat_log_messages.sort_by(:timestamp).map { |l| "#{l.created_at} #{l.message}"}.reverse
        else
          list = []
        end
        
        template = BorderedPagedListTemplate.new list, self.page, 25, t('tdscombat.log_title')
        client.emit template.render
      end
    end
  end
end