module Locale
  def set_locale

    # note: cookie(change before) > user.lang(registered) > browser > default
    locale = if params[:locale] && I18n.available_locales.include?(params[:locale].to_sym)
             # Return cookie if user change locale
                params[:locale].to_sym
                cookies[:locale] = params[:locale]
             elsif cookies[:locale] && I18n.available_locales.include?(cookies[:locale].to_sym)
                cookies[:locale]
             # Return db setting if registered user haven't change before
             elsif user_signed_in? && I18n.available_locales.include?(current_user.language.to_sym)
               current_user.language
             elsif request.env['HTTP_ACCEPT_LANGUAGE']
               check_browser_locale(request.env['HTTP_ACCEPT_LANGUAGE'])
             else
               I18n.default_locale
             end

    if locale
      current_user.change_locale!(locale.to_s) if user_signed_in?
      I18n.locale = locale
    end

    # language select option
    @locale_options = { :English => 'en',
                        :Deutsch => 'de',
                        :Nederlands => 'nl',
                        :"正體中文" => "zh-TW",
                        :"ไทย" => 'th',
                        :"Türkçe" => 'tr'}
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