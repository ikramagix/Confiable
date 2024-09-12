class Promise < ApplicationRecord
  # Associations
  belongs_to :politician # Each promise belongs to one politician
  has_many :actions, dependent: :destroy # A promise can have multiple actions related to fulfilling it
  has_many :comments, dependent: :destroy # Users can comment on promises

  # Validations
  validates :title, presence: true # Ensures that each promise has a title
  validates :description, presence: true # Ensures that each promise has a description
  validates :status, presence: true, inclusion: { in: %w[pending in_progress fulfilled failed] } # Status of the promise with predefined options

  # Scopes
  scope :by_status, ->(status) { where(status: status) } # Filter promises by status
  scope :recent, -> { order(created_at: :desc) } # Order promises by most recent

  # Search scope
  scope :search, ->(query) { where("title ILIKE ? OR description ILIKE ?", "%#{query}%", "%#{query}%") }


  # Instance Methods
  def progress_summary
    "#{actions.count} action(s) entreprise(s) pour tenir cette promesse." # Summarizes the number of actions related to this promise
  end
end
