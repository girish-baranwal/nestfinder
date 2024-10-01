class UserBlueprint < Blueprinter::Base
  identifier :id

  fields :email, :name, :phone_number
  association :properties, blueprint: PropertyBlueprint
end
