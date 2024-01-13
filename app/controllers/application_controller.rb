class ApplicationController < ActionController::API

  def bool(string)
    ActiveModel::Type::Boolean.new.cast(string)
  end
end
