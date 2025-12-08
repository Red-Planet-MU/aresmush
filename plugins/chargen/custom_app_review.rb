module AresMUSH
  module Chargen
    def self.custom_app_review(char)
      age = char.age.to_i
      points = FS3Skills::AbilityPointCounter.total_points(char) 
      
      case age
      when 20..25
        points_for_age = 35
      when 26..30
        points_for_age = 38
      when 31..35
        points_for_age = 41
      when 36..40
        points_for_age = 43
      when 41..45
        points_for_age = 47
      when 46..99
        points_for_age = 50
      end

      messages = []
      error_found = false
  
      if ((20..25) === age) && points <= 35
        messages << Chargen.format_review_status("Checking the right points for your age. (35 max)",  t('chargen.ok'))
      elsif ((26..30) === age) && points <= 38
        messages << Chargen.format_review_status("Checking the right points for your age. (38 max)",  t('chargen.ok'))
      elsif ((31..35) === age) && points <= 41
        messages << Chargen.format_review_status("Checking the right points for your age. (41 max)",  t('chargen.ok'))
      elsif ((36..40) === age) && points <= 43
        messages << Chargen.format_review_status("Checking the right points for your age. (43 max)",  t('chargen.ok'))
      elsif ((41..45) === age) && points <= 47
        messages << Chargen.format_review_status("Checking the right points for your age. (47 max)",  t('chargen.ok'))
      elsif ((46..99) === age) && points <= 50
        messages << Chargen.format_review_status("Checking the right points for your age. (50 max)",  t('chargen.ok'))
      else 
        messages << Chargen.format_review_status("Checking the right points for your age. (#{points_for_age} max)", "%r%xh%xr     < You have spent too many points for your age. >%xn")
      end

      return messages.join("\n")  

    end
  end
end