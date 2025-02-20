module AresMUSH
  module TDSSkills
    class AbilityPageTemplate < ErbTemplateRenderer


      attr_accessor :data
      
      def initialize(file, data)
        @data = data
        super File.dirname(__FILE__) + file
      end
      
      def page_footer
        footer = t('pages.page_x_of_y', :x => @data[:page], :y => @data[:num_pages])
        template = PageFooterTemplate.new(footer)
        template.render
      end
      
      def attr_blurb
        TDSSkills.attr_blurb
      end
      
      def advantages_blurb
        TDSSkills.advantages_blurb
      end
      
      def action_blurb
        TDSSkills.action_blurb
      end
      
      def bg_blurb
        TDSSkills.bg_blurb
      end
      
      def lang_blurb
        TDSSkills.language_blurb
      end
      
    end
  end
end