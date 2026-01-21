module AresMUSH
  module Socializer
    class WebManagePatientsHandler
      def handle(request)
        enactor = request.enactor
        #target_name = request.args['target']
        #target = Character.named(target_name)

        patient_names = request.args['patients'] || []
        patients = []
        

        error = Website.check_login(request)
        return error if error
        
        current_patients = enactor.patients.map { |p| p.name }
        enactor.patients.each do |p|
          if !patient_names.include?(p)
            healing = Healing.find(character_id: enactor.id).combine(patient_id: p.id).first
            healing.delete
          end
        end
        patient_names.each do |p|
          patient = Character.find_one_by_name(p.strip)
          if (patient)
            if (enactor.patients.include?(patient))
              return { error: t('fs3combat.already_healing', :name => patient.name) }
            end
            if (enactor.patients.count >= FS3Combat.max_patients(enactor))
              return { error: t('fs3combat.no_more_patients')}
            end
            Healing.create(character: enactor, patient: patient)
          end
        end
                    
        {}
      end
    end
  end
end