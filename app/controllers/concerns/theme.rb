module Theme
  extend ActiveSupport::Concern

  included do

    helper_method :theme

    def default_theme
      'blue'
    end

    def theme
      @theme = params[:theme] || cookies[:theme]
      @theme = default_theme unless @theme.try(:to_sym).in?(themes)
      cookies.permanent[:theme] = { value: @theme, httponly: true }
      @theme
    end

    def themes
      @themes ||= [:red, :orange, :yellow, :green, :blue]
    end
  end
end