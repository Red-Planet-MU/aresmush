module AresMUSH
  module TDSSkills
    class AbilitiesRequestHandler
      def handle(request)
        attrs = TDSSkills.attrs.map { |a| { name: a['name'].titleize, description: a['desc'] } }
        backgrounds = TDSSkills.background_skills.map { |name, desc| { name: name, description: desc } }
        action_skills = TDSSkills.action_skills.sort_by { |a| a['name'] }.map { |a| {
          name: a['name'].titleize,
          linked_attr: a['linked_attr'],
          description: a['desc'],
          specialties: a['specialties'] ? a['specialties'].join(', ') : nil,
        }}
        languages = TDSSkills.languages.sort_by { |a| a['name'] }.map { |a| { name: a['name'], description: a['desc'] } }
        advantages = TDSSkills.advantages.sort_by { |a| a['name'] }.map { |a| { name: a['name'], description: a['desc'] } }
        
        {
          attrs_blurb: Website.format_markdown_for_html(TDSSkills.attr_blurb),
          action_blurb: Website.format_markdown_for_html(TDSSkills.action_blurb),
          background_blurb: Website.format_markdown_for_html(TDSSkills.bg_blurb),
          language_blurb: Website.format_markdown_for_html(TDSSkills.language_blurb),
          advantages_blurb:  Website.format_markdown_for_html(TDSSkills.advantages_blurb),          
          
          attrs: attrs,
          action_skills: action_skills,
          backgrounds: backgrounds,
          languages: languages,
          advantages: advantages,
          use_advantages: TDSSkills.use_advantages?
        } 
      end
    end
  end
end


