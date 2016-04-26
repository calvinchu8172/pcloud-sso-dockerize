module Locale
  extend ActiveSupport::Concern

  included do

    before_action :set_locale

    def set_locale

      # note: cookie(change before) > user.lang(registered) > browser > default
      locale = if params[:locale]
               # Return cookie if user change locale
                  params[:locale].to_sym if I18n.available_locales.include?(params[:locale].to_sym)
               elsif cookies[:locale]
                  cookies[:locale] if I18n.available_locales.include?(cookies[:locale].to_sym)
               # Return db setting if registered user haven't change before
               elsif user_signed_in?
                 current_user.language if I18n.available_locales.include?(current_user.language.to_sym)
               elsif request.env['HTTP_ACCEPT_LANGUAGE']
                 check_browser_locale(request.env['HTTP_ACCEPT_LANGUAGE'])
               end

      locale = I18n.default_locale unless locale

      # work around for cucumber test if test OS env is not default English
      locale = I18n.default_locale if Rails.env == 'test'

      if locale
        cookies[:locale] = locale.to_s
        I18n.locale = locale
      end

      # language select option
      @locale_options = { :English => 'en',
                          :Deutsch => 'de',
                          :Nederlands => 'nl',
                          :"正體中文" => "zh-TW",
                          :"ไทย" => 'th',
                          :"Türkçe" => 'tr',
                          :"Čeština" => 'cs',
                          :"русский" => 'ru',
                          :"Polski" => 'pl',
                          :"Italiano" => 'it',
                          :"Magyar" => 'hu',
                          :"Français" => 'fr',
                          :"Español" => 'es'}

      @options_path = {}
      @locale_options.each do |key, value|
        @options_path[key] = params.merge(locale: value)
      end
    end


    # Split browser locales array and find first support language
    def check_browser_locale(browser_langs)
      accept_locales = []
      browser_langs.split(',').each do |l|
       l = l.split(';').first
       i = l.split('-')
       if 2 == i.size
         accept_locales << i[0].to_sym
         i[1].upcase!
       end
       l = i.join('-').to_sym
       accept_locales << l.to_sym
      end
      (accept_locales.select { |l| I18n.available_locales.include?(l) }).first
    end
  end
end
