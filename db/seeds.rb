# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
properties = Property.create([
                               title: 'Sample Property',
                               price: '20000',
                               description: 'Sample Property Description',
                               status: 'Active',
                               address_line_1: 'addline1',
                               address_line_2: 'addline2',
                               city: 'Bengaluru',
                               postal_code: '560067'
])