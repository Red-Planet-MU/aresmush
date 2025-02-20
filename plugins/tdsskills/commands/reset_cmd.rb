module AresMUSH

  module TDSSkills
    class ResetCmd
      include CommandHandler

      def check_chargen_locked
        Chargen.check_chargen_locked(enactor)
      end

      def handle
        TDSSkills.reset_char(enactor)        
        client.emit_success t('fs3skills.reset_complete')
      end
    end
  end
end
