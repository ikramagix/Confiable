class User < ApplicationRecord
    # Devise modules for authentication
    devise :database_authenticatable, :registerable,
           :recoverable, :rememberable, :validatable

    # Associations
    has_many :comments, dependent: :destroy # Users can comment on promises
end
