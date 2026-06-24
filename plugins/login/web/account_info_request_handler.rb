module AresMUSH
  module Login
    class AccountInfoRequestHandler
      def handle(request)      
        enactor = request.enactor
        
        error = Website.check_login(request)
        return error if error
        
        timezones = OOCTime.timezone_aliases.keys.concat OOCTime.timezone_names.sort
        
        {
          id: enactor.id,
          handle: enactor.handle ? enactor.handle.name : nil,
          email: enactor.login_email,
          alias: enactor.alias,
          name: enactor.name,
          timezone: enactor.ooctime_timezone,
          timezones: timezones,
          unified_play_screen: enactor.unified_play_screen,
          editor: enactor.website_editor || "Classic",
          editors: [ "Classic", "WYSIWYG" ],
          backup: enactor.wiki_char_backup ? enactor.wiki_char_backup.download_path : nil,
          highlight_name: enactor.highlight_name,
          highlight_name_color: enactor.highlight_name_color,
          highlight_name_bg_color: enactor.highlight_name_bg_color,
        }
      end
    end
  end
end