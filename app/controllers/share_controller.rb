class ShareController < ActionController::Base
  layout "application"

  def show
    @record = Record.find_by share_token: params[:share_token]
    if @record != nil
      authenticate_or_request_with_http_basic do |username, password|
        username.force_encoding("utf-8") == @record.username && password.force_encoding("utf-8") == @record.password
      end
      publish_event('share_access', { record: @record })
    else
      flash[:error] = "Share url is invalid. Please check again."
      redirect_to root_path
    end
  end
end