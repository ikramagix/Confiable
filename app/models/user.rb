class User < ApplicationRecord
    # Devise modules for authentication
    devise :database_authenticatable, :registerable,
           :recoverable, :rememberable, :validatable

    # Associations
    has_many :comments, dependent: :nullify # Users can comment on promises
    has_many :votes, dependent: :nullify # Assuming users can vote on promises or other content

    # Callbacks
    before_destroy :check_active_engagements

    private

    # Callback methods
    def check_active_engagements
      # Prevent deletion if the user has active engagements (e.g., comments, votes)
      if comments.exists? || votes.exists? || improvements.exists?
        errors.add(:base, "Impossible to delete a user with active engagements.")
        throw :abort
      end
    end
end
