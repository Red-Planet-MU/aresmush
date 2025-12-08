module AresMUSH
  module Chargen
    def self.custom_app_review(char)
      age = char.age.to_i
      points = FS3Skills::AbilityPointCounter.total_points(char) 
  
      messages = []
      error_found = false
  
      if ((20..25) === age) && points <= 35
        messages << Chargen.format_review_status("Checking the right points for your age",  t('chargen.ok'))
      elsif ((26..30) === age) && points <= 38
        messages << Chargen.format_review_status("Checking the right points for your age",  t('chargen.ok'))
      elsif ((31..35) === age) && points <= 41
        messages << Chargen.format_review_status("Checking the right points for your age",  t('chargen.ok'))
      elsif ((36..40) === age) && points <= 43
        messages << Chargen.format_review_status("Checking the right points for your age",  t('chargen.ok'))
      elsif ((41..45) === age) && points <= 47
        messages << Chargen.format_review_status("Checking the right points for your age",  t('chargen.ok'))
      elsif ((46..99) === age) && points <= 50
        messages << Chargen.format_review_status("Checking the right points for your age",  t('chargen.ok'))
      else 
        messages << Chargen.format_review_status("Checking the right points for your age", "%r%xr< You have spent too many points for your age. >%xn")
      end

      return messages.join("\n")  

    end
  end
end