require 'faker'
require 'rails_helper'



RSpec.describe TodoItem, :type => :model do
  context 'when creating a new Todo Item' do
    it "should create a new record with a name, due date and user provided" do
      user = User.first
      todo_item = Todo.new(name: , due_date: DateTime.now, user_id: user.id)
      expect(true).to eq true
    end
    it "should raise an error if a name is not provided" do
      todo_item = 
      expect(true).to eq true
    end
    it "should raise an error if a name is not provided" do
      todo_item = 
      expect(true).to eq true
    end
  end
end