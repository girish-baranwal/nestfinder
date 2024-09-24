class Agreement < ApplicationRecord
  belongs_to :property
  belongs_to :tenant
  belongs_to :owner
end
