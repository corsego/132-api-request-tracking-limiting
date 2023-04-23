class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :api_tokens
  has_many :api_requests
  has_many :posts

  MAX_API_REQUESTS_PER_30_DAYS = 50

  def api_requests_within_last_30_days
    api_requests.where("created_at > ?", 30.days.ago).count
  end

  def api_request_limit_exceeded?
    api_requests_within_last_30_days >= MAX_API_REQUESTS_PER_30_DAYS
  end
end
