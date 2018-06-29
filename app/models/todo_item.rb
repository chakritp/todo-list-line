class TodoItem < ApplicationRecord
  belongs_to :user

  validates :name, :due_date, presence: true
end
