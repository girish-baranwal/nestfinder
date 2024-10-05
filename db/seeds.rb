# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
# db/seeds.rb

# 1. Seeding users
puts "Seeding users..."

User.create!(
  [
    { name: 'John Doe', email: 'john@example.com', phone_number: '1234567890', role: 'user', password: 'password123', language: 'en' },
    { name: 'Jane Smith', email: 'jane@example.com', phone_number: '1234567891', role: 'user', password: 'password123', language: 'en' }
  ]
)

puts "Users seeded!"

# 2. Seeding properties

puts "Seeding properties..."

Property.create!([
                   {
                     user_id: 2,
                     title: '2 BHK Silas Whitefield',
                     price: 23000,
                     description: 'A lovely apartment located in the heart of the city.',
                     status: 'available',
                     address_line_1: 'Bellandur',
                     address_line_2: '',
                     city: 'Bengaluru',
                     postal_code: '560065'
                   },
                   {
                     user_id: 3,
                     title: 'Spacious Suburban House',
                     price: 30000,
                     description: 'A large house with a beautiful garden.',
                     status: 'available',
                     address_line_1: '456 Bellandur',
                     address_line_2: '',
                     city: 'Bengaluru',
                     postal_code: '560065'
                   }
                 ])

# Attach images to properties
property1 = Property.first
property1.images.attach(io: File.open(Rails.root.join('app/assets/images/image-1.jpeg')), filename: 'image-1.jpeg')
property1.images.attach(io: File.open(Rails.root.join('app/assets/images/image-2.jpeg')), filename: 'image-2.jpeg')

property2 = Property.second
property2.images.attach(io: File.open(Rails.root.join('app/assets/images/image-3.jpeg')), filename: 'image-3.jpeg')
property2.images.attach(io: File.open(Rails.root.join('app/assets/images/image-4.jpeg')), filename: 'image-4.jpeg')

puts "Properties seeded!"

# 3. Seeding rental agreements
puts "Seeding rental agreements..."

Agreement.create!(
  [
    {
      property_id: Property.first.id,
      owner_id: 2,
      status: 'draft',
      start_date: Date.today,
      end_date: Date.today + 1.year,
      rent_amount: 23000,
      deposit_amount: 100000,
      maintenance_amount: 3000,
      tenant_name: 'john',
      tenant_email: 'john@freshworks.com',
      owner_signature: 'Girish_Signature',
      owner_signed_at: Date.today,
      tenant_signature: nil,
      tenant_signed_at: nil,
    },
    {
      property_id: Property.second.id,
      owner_id: 3,
      status: 'completed',
      start_date: Date.today - 1.year,
      end_date: Date.today,
      rent_amount: 30000,
      deposit_amount: 100000,
      maintenance_amount: 3000,
      tenant_name: 'John Doe',
      tenant_email: 'john@example.com',
      owner_signature: 'User3_Signature',
      owner_signed_at: Date.today,
      tenant_signature: "John Doe",
      tenant_signed_at: Date.today - 1.year,
    }
  ]
)

puts "Rental agreements seeded!"
