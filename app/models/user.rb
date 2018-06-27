class User < ApplicationRecord
  has_many :todo_items
end
