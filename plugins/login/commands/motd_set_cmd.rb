module AresMUSH
  module Login
    class MotdSetCmd
      include CommandHandler

      attr_accessor :notice
      
      def parse_args
        args = cmd.parse_args(ArgParser.arg1_equals_arg2)
        self.subject = args.arg1
        self.notice = args.arg2
      end
      
      def check_can_set
        return t('dispatcher.not_allowed')  if !Login.can_manage_login?(enactor)
        return nil
      end
      
      def handle
        Game.master.update(login_motd: self.notice)
        client.emit_success t('login.motd_set')
        if (!self.notice.blank?)
          Manage.announce t('login.motd_announce', :enactor => enactor_name, :message => self.notice)
        end
        Forum.system_post(
          "Message of the Day Archive", 
          self.subject, 
          self.notice)
      end
    end
  end
end