module AresMUSH
  module FS3Combat
    class SerumAction < CombatAction
      attr_accessor  :serum_name, :has_target, :serum_has, :serum_type, :targets

      def prepare
        #Compare action args to see if a target is specified
        if (self.action_args =~ /\//)
          self.serum_name = self.action_args.before("/").titlecase
          self.targets = self.action_args.after("/")
          self.has_target = true
          #Global.logger.debug "self.name = #{self.name}; self.serum_name = #{self.serum_name}; self.targets = #{self.targets}"
        # If no target, set names list to the actor, ie self.name
        else
          self.targets = self.name
          self.serum_name = self.action_args.titlecase
          #Global.logger.debug "self.name = #{self.name}; self.serum_name = #{self.serum_name}; self.targets = #{self.targets}"
        end
        
        Global.logger.debug "self.name = #{self.name}; self.serum_name = #{self.serum_name}; self.targets = #{self.targets}"
        # Can only use serums one actually has
        self.serum_has = Serum.find_serums_has(combatant.associated_model, self.serum_name)
        return t('serum.dont_have_serum') if !self.serum_has

        error = self.parse_targets(self.targets)
        return error if error
        
        # Serums can only target one target
        return t('fs3combat.only_one_target') if (self.targets.count > 1)
        
        # If this is a healing serum, the target must have a treatable wound
        wound = FS3Combat.worst_treatable_wound(self.target.associated_model)
        self.serum_type = Serum.find_serums_type(self.serum_name)
        if (!wound) && self.serum_type == "v_serums_has"
          return t('fs3combat.target_has_no_treatable_wounds', :name => self.target.name)
        end
        
        #If this is a serum with a lasting effect, the last serum must expire first
        serum_duration = self.target.serum_duration_counter
        if serum_duration > 0
          return t('serum.already_serumed', :name => self.target.name)
        end

        #Don't let use a revive serum if they are not KO'd
        is_revive = Global.read_config('serum',self.serum_name,'is_revive')
        if is_revive && !self.target.is_ko
          return t('serum.not_ko', :target => self.target.name) 
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

        Global.logger.debug "Duration: #{duration} Init_mod: #{init_mod} Lethal_mod: #{lethal_mod} Lethality: #{lethality} armor_mod: #{armor_mod} is_healing: #{is_healing} is_revive: #{is_revive}"
        #Healing serums
        if is_healing == true 
          message = Serum.combat_healing_serum(combatant.associated_model,self.target.associated_model,self.serum_name)
        end

        #Serums that have a lasting effect
        if duration
          self.target.update(serum_duration_counter: duration)
          #ride on the default FS3 mod, which a GM may have set
          if init_mod
            self.target.update(serum_init_mod: init_mod)
          end

          #ride on the default FS3 mod, which a GM may have set
          if lethal_mod
            self.target.update(serum_damage_lethality_mod: lethal_mod)
          end

          #No default FS3 mods for this value
          if lethality
            self.target.update(serum_lethality_mod: lethality)
          end

          #No default FS3 mods for this value
          if armor_mod
            self.target.update(serum_armor_mod: armor_mod)
          end
          message = t('serum.used_serum_combat', :name => self.name, :target => print_target_names, :serum_name => self.serum_name)
        end

        if is_revive
          self.target.update(is_ko: false)
          message = t('serum.used_revive_serum', :name => self.name, :target => print_target_names, :serum_name => self.serum_name)
        end

        Serum.modify_serum(combatant.associated_model, self.serum_name, -1)
        [message]
      end
    end
  end
end