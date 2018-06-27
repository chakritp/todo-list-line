class AddUserToTodoItems < ActiveRecord::Migration[5.1]
  def change
    add_reference :todo_items, :user, foreign_key: true
  end
end
