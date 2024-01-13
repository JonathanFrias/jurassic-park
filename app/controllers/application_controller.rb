class ApplicationController < ActionController::API

  before_action :authorize_user

  def bool(string)
    ActiveModel::Type::Boolean.new.cast(string)
  end

  def authorize_user
    @current_user = User.find_by(token: request.headers['HTTP_X_API_KEY'])
    head :unauthorized unless @current_user
  end
end
