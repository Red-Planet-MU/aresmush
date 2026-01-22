module AresMUSH
    module Serum
      class SerumUseCommand
        include CommandHandler
  
        attr_accessor :serum_name, :char, :serum_type, :serum_has, :target, :combat_only_serum
  
        def parse_args
          args = cmd.parse_args(ArgParser.arg1_slash_optional_arg2)
          self.serum_name = titlecase_arg(args.arg1)
          self.char = titlecase_arg(args.arg2)
          self.serum_type = Serum.find_serums_type(self.serum_name)
          self.serum_has = Serum.find_serums_has(enactor, self.serum_name)
          if self.char
            self.target = Character.find_one_by_name(self.char)
          else
            self.target = enactor
          end
          self.combat_only_serum = Global.read_config('serum',self.serum_name,'combat_only')
        end
  
        def check_errors
          Global.logger.debug "self.serum_name: #{self.serum_name}"
          return t('serum.dont_have_serum') if Serum.find_serums_has(enactor, self.serum_name) < 1
          Global.logger.debug "self.combat_only_serum: #{self.combat_only_serum}"
          return t('serum.not_in_combat') if self.combat_only_serum == true && !enactor.combat
          wound = FS3Combat.worst_treatable_wound(self.target)
          return t('serum.no_healable_wounds', :target => self.target.name) if !wound
        end      
  
        def handle 
          heal_roll = TDD.parse_and_roll(enactor, "Medicine")
          heal_success_level = TDD.get_success_level(heal_roll)
          dice_message = TDD.print_dice(heal_roll)
          wound = FS3Combat.worst_treatable_wound(self.target)
          case heal_success_level
          when -1
            heal_amount = 0
            dice_message = t('tdd.botch')
            FS3Combat.inflict_damage(self.target, "MINOR", "Botched Serum")
            message = t('serum.used_v_made_it_worse', :name => enactor.name, :target => self.target.name, :serum_name => self.serum_name, :dice_result => dice_message)
          when 0
            heal_amount = 1
          when 1
            heal_amount = 3
          when 2
            heal_amount = 4
          when 3
            heal_amount = 6
          when 4
            heal_amount = 7
          when 5..15
            heal_amount = 8
          when 16..99
            heal_amount = 10
            dice_message = t('tdd.critical_success')
          end
          FS3Combat.heal(wound, heal_amount)

          if heal_success_level >= 0
            FS3Combat.heal(wound, heal_amount)
            message = t('serum.used_v_out_of_combat', :name => enactor.name, :target => self.target.name, :serum_name => self.serum_name, :heal_points => heal_amount, :dice_result => dice_message)
          end
          enactor.room.emit message
          if enactor.room.scene
            Scenes.add_to_scene(enactor.room.scene, message)
          end
          if self.target.room != enactor.room && message.to_s.include?(self.target.name)
            Login.emit_ooc_if_logged_in(self.target, "<OOC>%xn In another grid location, " + message)
          end
          Serum.modify_serum(enactor, self.serum_name, -1)
          enactor.update(serums_used: enactor.serums_used + 1)
          Serum.handle_serum_used_given_achievement(enactor)
        end
      end
    end
  end