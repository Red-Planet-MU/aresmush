module AresMUSH
  module FS3Skills
    class SheetTemplate < ErbTemplateRenderer
      
      attr_accessor :char, :screen_reader_on, :section
      
      def initialize(char, screen_reader_on, section = nil)
        @char = char
        @screen_reader_on = screen_reader_on
        @section = section
        super File.dirname(__FILE__) + "/sheet.erb"
      end
     
      def approval_status
        Chargen.approval_status(@char)
      end
      
      def luck
        @char.luck.floor
      end
      
      def show_section(section)
        sections = ['attributes', 'action', 'background', 'advantages']
        return true if self.section.blank?
        return true if !sections.include?(section)
        return true if !sections.include?(self.section)
        return section == self.section
      end
      
      def attrs
       list = []        
        @char.fs3_attributes.sort_by(:name, :order => "ALPHA").each_with_index do |a, i| 
          list << format_attr(a, i)
        end   
        list     
      end
        
      def action_skills
        list = []
        @char.fs3_action_skills.sort_by(:name, :order => "ALPHA").each_with_index do |s, i| 
           list << format_skill(s, i, true)
        end
        list
      end

      def background_skills
        list = []
        @char.fs3_background_skills.sort_by(:name, :order => "ALPHA").each_with_index do |s, i| 
           list << format_skill(s, i)
        end
        list
      end
      
      def languages
        list = []
        @char.fs3_languages.sort_by(:name, :order => "ALPHA").each_with_index do |l, i|
          list << format_skill(l, i)
        end
        list
      end
      
      def advantages
        list = []
        @char.fs3_advantages.sort_by(:name, :order => "ALPHA").each_with_index do |l, i|
          list << format_skill(l, i)
        end
        list
      end
      
      def use_advantages
        FS3Skills.use_advantages?
      end
            
      def specialties
        spec = {}
        @char.fs3_action_skills.each do |a|
          if (a.specialties)
            a.specialties.each do |s|
              spec[s] = a.name
            end
          end
        end
        return nil if (spec.keys.count == 0)
        spec.map { |spec, ability| "#{spec} (#{ability})"}.join(", ")
      end
      
      def format_attr(a, i)
        linebreak = i % 2 == 1 ? "" : "%r"
        if (self.screen_reader_on)
          return "#{linebreak}#{a.name}: #{a.rating} #{a.rating_name} :: "
        end
        name = "%xh#{a.name}:%xn"
        rating_text = "#{a.rating_name}"
        rating_dots = a.print_rating
        "#{linebreak}#{left(name, 14)} #{left(rating_dots, 8)} #{left(rating_text,16)}"
      end
      
      def format_skill(s, i, show_linked_attr = false)
        linked_attr = show_linked_attr ? print_linked_attr(s) : ""
        linebreak = i % 2 == 1 ? "" : "%r"
        
        if (self.screen_reader_on)
          return "#{linebreak}#{s.name}: #{s.rating} #{s.rating_name} #{linked_attr} :: "
        end
                
        name = "%xh#{s.name}:%xn"
        rating_text = "#{s.rating_name}#{linked_attr}"
        rating_dots = s.print_rating
        "#{linebreak}#{left(name, 14)} #{left(rating_dots, 8)} #{left(rating_text, 16)}"
      end
      
      def print_linked_attr(skill)
        apt = FS3Skills.get_linked_attr(skill.name)
        !apt ? "" : " %xh%xx(#{apt[0..2].upcase})%xn"
      end
      
      def section_line(title)
        self.screen_reader_on ? title : line_with_text(title)
      end

      def print_horse_rating(bond_rating)
        case bond_rating
        when 0
          return ""
        when 1
          return "%xg@%xn"
        when 2
          return "%xg@@%xn"
        when 3
          return "%xg@@%xy@%xn"
        when 4
          return "%xg@@%xy@@%xn"
        when 5
          return "%xg@@%xy@@%xr@%xn"
        when 6
          return "%xg@@%xy@@%xr@@%xn"
        when 7
          return "%xg@@%xy@@%xr@@%xb@%xn"
        when 8
          return "%xg@@%xy@@%xr@@%xb@@%xn"
        end
      end

      def horse_rating_name(bond_rating)
        case bond_rating
        when 0
          return t('horse.no_bond_rating')
        when 1
          return t('horse.first_bond_rating')
        when 2
          return t('horse.second_bond_rating')
        when 3
          return t('horse.third_bond_rating')
        when 4
          return t('horse.fourth_bond_rating')
        when 5
          return t('horse.fifth_bond_rating')
        when 6
          return t('horse.sixth_bond_rating')
        when 7
          return t('horse.seventh_bond_rating')
        when 8
          return t('horse.eighth_bond_rating')
        end
      end

      def format_bond(char)
        #linebreak = i % 2 == 1 ? "" : "%r"
        
        #if (self.screen_reader_on)
        #  return "#{linebreak}#{b.name}: #{b.rating} #{b.rating_name} :: "
        #end
        bond = char.horse_bond  
        name = "%xhHorse Bond:%xn"
        rating_text = horse_rating_name(bond)
        rating_dots = print_horse_rating(bond)
        #"#{left(rating_dots, 8)}"
        "#{left(name, 14)} #{left(rating_dots, 8)} #{left(rating_text, 16)}"
      end
    end
  end
end