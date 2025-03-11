module AresMUSH
  module FS3Combat
    class SerumAction < CombatAction
      attr_accessor  :serum_name, :has_target, :serum_has, :serum_type

      def prepare
        #Compare action args to see if a target is specified
        if (self.action_args =~ /\//)
          self.serum_name = self.action_args.before("/")
          names = self.action_args.after("/")
          self.has_target = true
        # If no target, set names list to the actor, ie self.name
        else
          names = self.name
          self.serum_name = self.action_args
        end
        Global.logger.debug "self.name = #{self.name}; self.serum_name = #{self.serum_name}; names = #{names}"
        # Can only use serums one actually has
        self.serum_has = Serum.find_serums_has(combatant.associated_model, self.serum_name)
        return t('serum.dont_have_serum') if !self.serum_has

        error = self.parse_targets(names)
        return error if error
        
        # Serums can only target one target
        return t('fs3combat.only_one_target') if (self.targets.count > 1)
        
        # If this is a healing serum, the target must have a treatable wound
        wound = FS3Combat.worst_treatable_wound(self.target.associated_model)
        self.serum_type = Serum.find_serums_type(self.serum_name)
        if (!wound) && self.serum_type == "v_serums_has"
          return t('fs3combat.target_has_no_treatable_wounds', :name => self.target.name)
        end                
        
        return nil
      end
      
      def print_action
        msg = t('serum.use_serum_action_msg_long', :name => self.name, :target => print_target_names, :serum_name => self.serum_name)
      end
      
      def print_action_short
        t('serum.use_serum_action_msg_short', :name => self.name, :target => print_target_names, :serum_name => self.serum_name)
      end
      
      def resolve
        duration = Global.read_config('serum',self.serum_name,'duration')
        init_mod = Global.read_config('serum',self.serum_name,'init_mod')
        lethal_mod = Global.read_config('serum',self.serum_name,'lethality_mod')
        lethality = Global.read_config('serum',self.serum_name,'lethality')
        armor_mod = Global.read_config('serum',self.serum_name,'armor_mod')
        is_healing = Global.read_config('serum',self.serum_name,'is_healing')
        is_revive = Global.read_config('serum',self.serum_name,'is_revive')
        message = Serum.combat_healing_serum(self.combatant.associated_model,names.associated_model)

        [message]
      end
    end
  end
end