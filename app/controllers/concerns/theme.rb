module Theme
  extend ActiveSupport::Concern

  included do

    attr_accessor :theme

    helper_method :theme

    prepend_before_action :set_theme

    def themes
      @themes ||= [:red, :orange, :yellow, :green, :blue]
    end

    def default_theme
      'blue'
    end

    def set_theme
      @theme = params[:theme] || cookies[:theme]
      @theme = default_theme unless @theme.try(:to_sym).in?(themes)
      cookies.permanent[:theme] = { value: @theme, httponly: true }
    end
  end
end
