module AresMUSH
  module Chargen
    def self.custom_app_review(char)
      age = char.age.to_i
      Global.logger.debug "age: #{age}"
      points = FS3Skills::AbilityPointCounter.total_points(char) 
      Global.logger.debug "points: #{points}"
  
      messages = []
      error_found = false
  
      case age
      when 20..25 && points <= 35
        messages << Chargen.format_review_status("Checking Points",  t('chargen.ok'))
      when 26..30 && points <= 38
        messages << Chargen.format_review_status("Checking Points",  t('chargen.ok'))
      when 31..35 && points <= 41
        messages << Chargen.format_review_status("Checking Points",  t('chargen.ok'))
      when 36..40 && points <= 43
        messages << Chargen.format_review_status("Checking Points",  t('chargen.ok'))
      when 41..45 && points <= 47
        messages << Chargen.format_review_status("Checking Points",  t('chargen.ok'))
      when 46..99 && points <= 50
        messages << Chargen.format_review_status("Checking Points",  t('chargen.ok'))
      else 
        messages << Chargen.format_review_status("Checking Points", "You have spent too many points for your age.")
      end

      return messages.join("\n")  

    end
  end
end