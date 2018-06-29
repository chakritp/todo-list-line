require 'faker'
require 'rails_helper'
require 'database_cleaner'

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation, { :except => %w[users] })
  end

  config.before(:suite) do
    User.create(name: Faker::Name.name, line_id: 'U' + Faker::String.random(32))
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end

RSpec.describe TodoItem, :type => :model do
  context 'when creating a new Todo Item' do
    it "should create a new record with a name, due date and user provided" do
      user = User.first
      todo_item = TodoItem.create(name: Faker::Name.name, due_date: DateTime.now, user_id: user.id)
      expect(TodoItem.count).to eq(1)
    end
    it "should raise an error if a name is not provided" do
      user = User.first
      todo_item = TodoItem.new(due_date: DateTime.now, user_id: user.id)
      expect(todo_item.save).to eq false
    end
    it "should raise an error if a due date is not provided" do
      user = User.first
      todo_item = TodoItem.new(name: Faker::Name.name, user_id: user.id)
      expect(todo_item.save).to eq false
    end
    it "should not save if a user is not provided" do
      todo_item = TodoItem.new(name: Faker::Name.name, due_date: DateTime.now)
      expect(todo_item.save).to eq(false)
      expect(TodoItem.count).to eq (0)
    end
  end
end