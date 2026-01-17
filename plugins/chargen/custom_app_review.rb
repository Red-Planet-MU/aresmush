module AresMUSH
  module Chargen
    def self.custom_app_review(char)
      # If you don't want to have any custom app review steps, return nil
      #return nil
            
      action_skills_above_2 = char.fs3_action_skills.select { |s| s.rating > 2 }.map { |s| s.name }
      combat_skills = Array(["Firearms", "Melee", "Archery"])
      combat_skills_above_2 = false
      messages = []
      
      Global.logger.debug "action_skills_above_2: #{action_skills_above_2}
      combat_skills: #{combat_skills}
      "
      combat_skills.each do |c|
        if (action_skills_above_2.include?(c))
          combat_skills_above_2 = true
          Global.logger.debug "combat_skills_above_2 after math: #{combat_skills_above_2}"
        end
      end

      Global.logger.debug "combat_skills_above_2 after loop: #{combat_skills_above_2}"
      if combat_skills_above_2
        messages << Chargen.format_review_status("Checking for combat skills.",  t('chargen.ok'))
      else 
        messages << Chargen.format_review_status("Checking for combat skills.", "%xr< Missing combat skill at 3+! >%xn")
      end
      

      return messages.join("\n")  
      # Otherwise, return a message to display.  Here's an example of how to 
      # give an alert if the character has chosen an invalid position for their 
      # faction.
      #
      #  faction = char.group("Faction")
      #  position = char.group("Position")
      #  
      #  if (position == "Knight" && faction != "Noble")
      #    msg = "%xrOnly nobles can be knights.%xn"
      #  else
      #    msg = t('chargen.ok')
      #  end
      #
      #  return Chargen.format_review_status "Checking groups.", msg
      #
      # You can also use other built-in chargen status messages, like t('chargen.not_set').  
      # See https://www.aresmush.com/tutorials/config/chargen.html for details.
    end
  end
end