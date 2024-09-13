class Comment < ApplicationRecord
  # Associations
  belongs_to :user # Each comment is made by a user
  belongs_to :promise # Each comment is related to a specific promise

  # Validations
  validates :content, presence: true # Ensures that each comment has content
  validates :user, presence: true # Ensures the comment is associated with a user
  validates :promise, presence: true # Ensures the comment is associated with a promise

  # Scopes
  scope :recent, -> { order(created_at: :desc) } # Orders comments by most recent

  # Instance Methods
  def short_content
    content.truncate(100) # Truncates the comment content to 100 characters for display
  end
end
