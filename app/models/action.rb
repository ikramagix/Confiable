class Action < ApplicationRecord
  # Associations
  belongs_to :promise # Each action is linked to a specific promise

  # Validations
  validates :description, presence: true # Ensures each action has a description
  validates :date, presence: true # Ensures the action has a date to indicate when it was taken

  # Scopes
  scope :recent, -> { order(date: :desc) } # Orders actions by most recent date first

  # Instance Methods
  def formatted_date
    date.strftime("%d %B %Y") # Formats the action date for display
  end
end