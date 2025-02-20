module AresMUSH
  module TDSSkills
    
    def self.print_dice(dice)
      dice.sort.reverse.map { |d| d >= TDSSkills.success_target_number ? "%xg#{d}%xn" : d}.join(" ")
    end
    
    
    def self.get_success_title(success_level)
      case success_level
      when -1
        #t('tdsskills.embarrassing_failure')
        t('tdsskills.botch')
      when 0
        t('tdsskills.failure')
      when 1, 2
        t('tdsskills.success')
      when 3, 4
        t('tdsskills.good_success')
      when 5, 6
        t('tdsskills.great_success')
      when 7..15
        t('tdsskills.amazing_success')
      when 16..99
        t('tdsskills.critical_success')
      else
        raise "Unexpected roll result: #{success_level}"
      end
    end
    
    def self.opposed_result_title(name1, successes1, name2, successes2)
      delta = successes1 - successes2
      
      if (successes1 <=0 && successes2 <= 0)
        return t('tdsskills.opposed_both_fail')
      end
      
      case delta
      when 3..99
        return t('tdsskills.opposed_crushing_victory', :name => name1)
      when 2
        return t('tdsskills.opposed_victory', :name => name1)
      when 1
        return t('tdsskills.opposed_marginal_victory', :name => name1)
      when 0
        return t('tdsskills.opposed_draw')
      when -1
        return t('tdsskills.opposed_marginal_victory', :name => name2)
      when -2
        return t('tdsskills.opposed_victory', :name => name2)
      when -99..-3
        return t('tdsskills.opposed_crushing_victory', :name => name2)
      else
        raise "Unexpected opposed roll result: #{successes1} #{successes2}"
      end
    end
    
    
  end
end
