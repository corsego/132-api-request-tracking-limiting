class Api::V1::AuthenticatedController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found

  protect_from_forgery with: :null_session

  before_action :authenticate
  before_action :check_api_limit
  before_action :log_api_request

  attr_reader :current_user

  def authenticate
    authenticate_user_with_token || handle_bad_authentication
  end

  private

  def authenticate_user_with_token
    authenticate_with_http_token do |token, options|
      current_api_token = ApiToken.where(active: true).find_by(token: token)
      @current_user = current_api_token&.user
      current_api_token.update(last_used_at: Time.zone.now)
    end
  end

  def check_api_limit
    if current_user.api_request_limit_exceeded?
      render json: { message: "API limit exceeded" }, status: :too_many_requests
    end
  end

  def log_api_request
    current_user.api_requests.create!(path: request.path, method: request.method)
    response.headers['X-SupeRails-Shop-Api-Call-Limit'] = "#{current_user.api_requests_within_last_30_days}/#{User::MAX_API_REQUESTS_PER_30_DAYS}"
  end

  def handle_bad_authentication
    render json: { message: "Bad credentials" }, status: :unauthorized
  end

  def handle_not_found
    render json: { message: "Record not found" }, status: :not_found
  end
end