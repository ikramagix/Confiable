class Politician < ApplicationRecord
    # Associations
    has_many :promises, dependent: :destroy # A politician has many promises

    # Validations
    validates :first_name, presence: true
    validates :last_name, presence: true 
    # Ensures the politician's name presence
    validates :position, presence: true # Ensures the position (e.g., President) is specified

    # Scopes & Search
    scope :by_position, ->(position) { where(position: position) } # Scope to filter politicians by their position
    scope :by_party, ->(party) { where(party: party) } # Scope to filter politicians by their party

    scope :search, ->(query) {
      where("first_name ILIKE :query OR last_name ILIKE :query OR position ILIKE :query OR party ILIKE :query", query: "%#{query}%") if query.present?
    }
end
