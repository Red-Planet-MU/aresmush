module AresMUSH
  module TDSCombat
    class CombatActionCmd
      include CommandHandler
      include NotAllowedWhileTurnInProgress
      
      attr_accessor :names, :action_args, :combat_command
           
      def parse_args
        if (cmd.args =~ /\=/)
          self.names = InputFormatter.titlecase_arg(cmd.args.before("="))
          self.action_args = cmd.args.after("=")
        elsif (cmd.args && one_word_command)
          self.names = InputFormatter.titlecase_arg(cmd.args)
          self.action_args = ""
        else
          self.names = enactor.name
          self.action_args = cmd.args
        end
        
        self.names = self.names ? self.names.split(/[ ,]/) : nil
        
        self.combat_command = cmd.switch ? cmd.switch.downcase : nil
      end
      
      def one_word_command
        switch = cmd.switch ? cmd.switch.downcase : nil
        switch == "pass" || switch == "reload" || switch == "evade"
      end
      
      def check_can_act
        return t('tdscombat.you_are_not_in_combat') if !enactor.is_in_combat?
        return t('tdscombat.cannot_act_while_koed') if (acting_for_self && enactor.combatant.is_ko)
        return t('tdscombat.you_are_a_noncombatant') if (acting_for_self && enactor.combatant.is_noncombatant?)
        return nil
      end
      
      def acting_for_self
        self.names &&
        self.names.count == 1 &&
        self.names[0] == enactor_name
      end
      
      def handle
        action_klass = TDSCombat.find_action_klass(self.combat_command)
        if (!action_klass)
          client.emit_failure t('tdscombat.unknown_command')
          return
        end
        
        self.names.each do |name|
        
          TDSCombat.with_a_combatant(name, client, enactor) do |combat, combatant|
            if (combatant.is_subdued? && self.combat_command != "escape")
              client.emit_failure t('tdscombat.must_escape_first') 
              next
            end
            error = TDSCombat.set_action(enactor, combat, combatant, action_klass, self.action_args)
            if (error)
              client.emit_failure error
            end
          end
        end
      end
    end
  end
end