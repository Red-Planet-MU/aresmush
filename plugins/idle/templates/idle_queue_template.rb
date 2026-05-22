module AresMUSH
  module Idle
    class IdleQueueTemplate < ErbTemplateRenderer

      
      attr_accessor :queue
      
      def initialize(list, enactor)
        @queue = []
        list.each do |k, v|
          @queue << { char: Character[k], action: v }
        end

        @enactor = enactor
        super File.dirname(__FILE__) + "/idle_queue.erb"
      end
      
      def name(entry)
        char = entry[:char]
        char.name
      end
      
      def sorted_queue
      	 @queue.sort_by { |q| last_on(q) }
      end
            
      def lastwill(entry)
        char = entry[:char]
        char.idle_lastwill
      end
      
      def idle_notes(entry)
        char = entry[:char]
        char.idle_notes
      end

      def days_out(entry)
        char = entry[:char]
        last_scene_shared = char.scenes_starring.sort_by { |s| s.date_shared }.reverse[0]
        if !char.approved_at
          idle_days = (Time.now - char.last_on) / 86400 
          idle_days - Global.read_config("idle", "days_before_very_idle")
        elsif !last_scene_shared 
          idle_days = (Time.now - char.approved_at) / 86400 
          idle_days - Global.read_config("idle", "days_before_very_idle")
        else 
          idle_days = (Time.now - last_scene_shared.date_shared) / 86400 
          idle_days - Global.read_config("idle", "days_before_very_idle")
        end
      end
      
      def last_on(entry)
        char = entry[:char]
        str = OOCTime.local_short_timestr(@enactor, char.last_on)
        if (char.idle_warned)
          str += '*'
        end
        str
      end
      
      def action(entry)
      	color = Idle.idle_action_color(entry[:action])
      	"#{color}#{entry[:action]}%xn"
      end            
      
      def highlight_color(entry)
        char = entry[:char]
        char.is_approved? ? "%xh%xg" : ""
      end
      
      
    end
  end
end