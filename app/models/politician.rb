class Politician < ApplicationRecord
    # Associations
    has_many :promises, dependent: :destroy # A politician has many promises
  
    # Validations
    validates :name, presence: true, uniqueness: true # Ensures the politician's name is present and unique
    validates :party, presence: true # Ensures the party is specified
    validates :position, presence: true # Ensures the position (e.g., President) is specified
  
    # Scopes
    scope :by_position, ->(position) { where(position: position) } # Scope to filter politicians by their position
    scope :by_party, ->(party) { where(party: party) } # Scope to filter politicians by their party
  
    # Instance Methods
    def full_title
      "#{name}, #{position} de #{party}"
    end
  end
  