module AresMUSH
  module TDSSkills
    class CharAbilitiesRequestHandler
      def handle(request)
        char = Character.find_one_by_name request.args[:id]
        enactor = request.enactor
        
        if (!char)
          return []
        end

        error = Website.check_login(request, true)
        return error if error
        
        
        can_view = TDSSkills.can_view_sheets?(enactor) || (enactor && enactor.id == char.id)
        if (!can_view)
          return { error: t('dispatcher.not_alllowed') }
        end
        
        abilities = []
      
        [ char.tds_attributes, char.tds_action_skills, char.tds_background_skills, char.tds_languages, char.tds_advantages ].each do |list|
          list.each do |a|
            abilities << a.name
          end
        end
        
        return abilities
      end
    end
  end
end