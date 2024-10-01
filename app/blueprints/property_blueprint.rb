class PropertyBlueprint < Blueprinter::Base
  identifier :id

  fields :title, :price, :description, :status, :address_line_1, :address_line_2,
         :city, :postal_code, :latitude, :longitude, :created_at, :updated_at

  # Add associations if needed (for example, user or images)
  # association :comments, blueprint: CommentBlueprint
end
