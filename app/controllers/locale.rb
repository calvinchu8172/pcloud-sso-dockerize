module Locale
  def set_locale

    # note: cookie(change before) > user.lang(registered) > browser > default
    locale = if params[:locale]
             # Return cookie if user change locale
                params[:locale].to_sym if I18n.available_locales.include?(params[:locale].to_sym)
                cookies[:locale] = params[:locale]
             elsif cookies[:locale]
                cookies[:locale] if I18n.available_locales.include?(cookies[:locale].to_sym)

             # Return db setting if registered user haven't change before
             elsif user_signed_in?
               current_user.language if I18n.available_locales.include?(current_user.language.to_sym)

             elsif request.env['HTTP_ACCEPT_LANGUAGE']
               check_browser_locale(request.env['HTTP_ACCEPT_LANGUAGE'])

             else
               I18n.available_locales.first unless locale
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
end