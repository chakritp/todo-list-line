require 'faker'
require 'rails_helper'
require 'database_cleaner'

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with :truncation
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end

RSpec.describe User, :type => :model do
  context 'when creating a new User' do
    it "should create a new record with a name and LINE ID provided" do
      user = User.new(name: Faker::Name.name, line_id: 'U' + Faker::Number.number(32))
      expect(user.save).to eq true
      expect(User.count).to eq 1
    end
    it "shouldn't save if the LINE ID is not 33 characters long" do
      user = User.new(name: Faker::Name.name, line_id: 'U' + Faker::Number.number(31))
      expect(user.save).to eq false
      expect(User.count).to eq 0
    end
    it "should be able to have TodoItems" do
      user = User.create(name: Faker::Name.name, line_id: 'U' + Faker::Number.number(32))
      todo_item = TodoItem.create(name: Faker::Name.name, due_date: DateTime.now, user_id: user.id)

      expect(User.count).to eq 1
      expect(todo_item.user).to eq(user)
      expect(user.todo_items.first.id).to eq(todo_item.id)
      expect(user.todo_items.count).to eq(1)
    end
  end
end