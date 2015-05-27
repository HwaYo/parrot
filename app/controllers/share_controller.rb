class ShareController < ActionController::Base
  layout "application"
  
  def show
    @record = Record.find_by! share_token: params[:share_token]

    authenticate_or_request_with_http_basic do |username, password|
      username == @record.username && password == @record.password
    end
  end
end