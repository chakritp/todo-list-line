class CreateTodoItems < ActiveRecord::Migration[5.1]
  def change
    create_table :todo_items do |t|
      t.string :name
      t.datetime :due_date
      t.boolean :is_important, default: false
      t.boolean :is_completed, default: false

      t.timestamps
    end
  end
end
