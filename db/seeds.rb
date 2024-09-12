# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# db/seeds.rb

require "faker"

# Clear existing data
Comment.destroy_all
Action.destroy_all
Promise.destroy_all
Politician.destroy_all
User.destroy_all

# Create Users
puts 'Creating users...'
users = []
5.times do
  users << User.create!(
    email: Faker::Internet.unique.email,
    username: Faker::Internet.unique.username,
    role: %w[user admin].sample,
    encrypted_password: 'confifi', # Devise requires a password
    created_at: Faker::Time.between(from: 1.year.ago, to: Time.now),
    updated_at: Faker::Time.between(from: 1.year.ago, to: Time.now)
  )
end

# Create Politicians
puts 'Creating politicians...'
politicians = []
5.times do
  politicians << Politician.create!(
    name: Faker::Name.name,
    party: Faker::Company.name,
    position: %w[Mayor Senator Governor President].sample,
    created_at: Faker::Time.between(from: 1.year.ago, to: Time.now),
    updated_at: Faker::Time.between(from: 1.year.ago, to: Time.now)
  )
end

# Create Promises
puts 'Creating promises...'
promises = []
10.times do
  promises << Promise.create!(
    title: Faker::Lorem.sentence(word_count: 3),
    description: Faker::Lorem.paragraph(sentence_count: 2),
    politician: politicians.sample,
    status: %w[pending fulfilled broken].sample,
    created_at: Faker::Time.between(from: 1.year.ago, to: Time.now),
    updated_at: Faker::Time.between(from: 1.year.ago, to: Time.now)
  )
end

# Create Actions
puts 'Creating actions...'
20.times do
  Action.create!(
    promise: promises.sample,
    description: Faker::Lorem.paragraph(sentence_count: 1),
    date: Faker::Time.between(from: 6.months.ago, to: Time.now),
    created_at: Faker::Time.between(from: 1.year.ago, to: Time.now),
    updated_at: Faker::Time.between(from: 1.year.ago, to: Time.now)
  )
end

# Create Comments
puts 'Creating comments...'
30.times do
  Comment.create!(
    user: users.sample,
    promise: promises.sample,
    content: Faker::Lorem.paragraph(sentence_count: 2),
    created_at: Faker::Time.between(from: 1.year.ago, to: Time.now),
    updated_at: Faker::Time.between(from: 1.year.ago, to: Time.now)
  )
end

puts 'Seeding completed successfully!'
