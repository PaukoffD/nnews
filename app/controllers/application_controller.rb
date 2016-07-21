class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :detect_browser
  before_filter :set_global_search_variable

  def detect_browser
    request.variant = case request.user_agent
                      when /iPad/i
                        :tablet
                      when /iPhone/i
                        :phone
                      when /Android/i && /mobile/i
                        :phone
                      when /Android/i
                        :tablet
                      when /Windows Phone/i
                        :phone
                      else
                        :desktop
                      end
  end

  def set_global_search_variable
    @q = Page.search(params[:q])
    end
end
