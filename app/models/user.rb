class User < ApplicationRecord
  has_many :todo_items

  validates :line_id, presence: true, length: { is: 33 }
end
