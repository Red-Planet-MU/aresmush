module AresMUSH
    module Serum
      class SerumUseCommand
        include CommandHandler
  
        attr_accessor :serum_name, :char, :serum_type, :serum_has, :target, :combat_only_serum
  
        def parse_args
          args = cmd.parse_args(ArgParser.arg1_equals_optional_arg2)
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
          return t('serum.dont_have_serum') if Serum.find_serums_has(enactor, self.serum_name) < 1
          return t('serum.not_in_combat') if self.combat_only_serum == true && !enactor.combat
          wound = FS3Combat.worst_treatable_wound(self.target)
          return t('serum.no_healable_wounds', :target => self.target.name) if wound.blank?
        end      
  
        def handle
          heal_roll = TDD.roll_ability(enactor, "Medicine")
          Global.logger.debug "heal roll: #{heal_roll}"
        end
      end
    end
  end