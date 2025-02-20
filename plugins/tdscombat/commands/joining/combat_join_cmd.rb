module AresMUSH
  module TDSCombat
    class CombatJoinCmd
      include CommandHandler
      include NotAllowedWhileTurnInProgress
      
      attr_accessor :names, :num, :combatant_type
      
      def parse_args
        if (cmd.args =~ /=/)
          args = cmd.parse_args(ArgParser.arg1_equals_arg2_slash_optional_arg3)
          self.names = titlecase_list_arg(args.arg1, /[ ,]/)
          self.num = trim_arg(args.arg2)
          self.combatant_type = titlecase_arg(args.arg3)
        else
          args = cmd.parse_args(ArgParser.arg1_slash_optional_arg2)
          self.names = [ enactor_name ]
          self.num = titlecase_arg(args.arg1)
          self.combatant_type = titlecase_arg(args.arg2)
        end
      end

      def required_args
        [ self.names, self.num ]
      end
      
      def check_type
        return nil if !self.combatant_type       
        return t('tdscombat.invalid_combatant_type') if !TDSCombat.combatant_types.include?(self.combatant_type)
        return t('tdscombat.use_vehicle_type_cmd') if TDSCombat.passenger_types.include?(self.combatant_type)
        return nil
      end
      
      def handle
        combat = TDSCombat.find_combat_by_number(client, self.num)
        return if !combat
        
        type = self.combatant_type || TDSCombat.default_combatant_type
        
        self.names.each_with_index do |n, i|
          TDSCombat.join_combat(combat, n, type, enactor, client)
        end
      end
    end
  end
end