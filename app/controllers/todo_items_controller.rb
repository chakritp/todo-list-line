class TodoItemsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :verify_signature, only: :message_callback
  
  def message_callback
    request_body = JSON.parse(request.body.read)
    
    puts "request body: " + request_body.inspect

    user_id = request_body["events"][0]["source"]["userId"]
    get_user(user_id)

    message_type = request_body["events"][0]["message"]["type"]
    message_text = request_body["events"][0]["message"]["text"]
    reply_token = request_body["events"][0]["replyToken"]
    
    #parse message
    #conditions:
    # 1. edit -> show link to edit page
    # 2. task : today : time
    # 3. list

    reply_text = ""
    auth_link = "https://access.line.me/oauth2/v2.1/authorize?response_type=code&client_id=#{ENV['LINE_CHANNEL_ID']}&redirect_uri=#{ENV['REDIRECT_URI']}&state=#{ENV['STATE']}&scope=openid%20profile"

    begin
      case message_text.downcase
      when 'edit'
        "You Selected Edit"
        reply_text = "Here is the link to edit your TODOs: #{auth_link}"
      when /\s*(:)\s*/
        task_name = message_text.split(/\s*(:)\s*/, 3)[0]
        date = message_text.split(/\s*(:)\s*/, 3)[2]
        time = message_text.split(/\s*(:)\s*/, 3)[4]
        
        raise if task_name.nil? || date.nil? 

        date = case date
        when 'today'
          Date.today
        when 'tomorrow'
          Date.today + 1.day
        else
          Date.strptime(date, '%d/%m/%y')
        end

        time = '12:00' if time.nil?
        hours = time.split(':')[0].to_i
        minutes = time.split(':')[1].to_i
        date_time = DateTime.new(date.year, date.month, date.day, hours, minutes)

        # Create Task
        todo_item = TodoItem.new(name: task_name, due_date: date_time, user_id: @user.id)
        
        if todo_item.save
          reply_text = "Created Task\nName: #{todo_item.name}\nDue Date: #{todo_item.due_date.strftime('%H:%M %e/%m/%y')}"
        end
        # "Task: #{task_name}, Due Date: #{date_time.inspect}"
      else
        raise
      end
    rescue Exception => e
      Rails.logger.debug e.inspect
      reply_text = "Sorry but that's an invalid option. Please ensure the format is correct."
    end

    reply_message = {
      type: 'text',
      text: reply_text
    }

    response = client.reply_message(reply_token, reply_message)

    render json: {
      text: "Ok",
      status: 200
    }
  end
  
  def index
    @user = User.find_by(id: params[:user_id])
    @incomplete_todo_items = TodoItem.where(user_id: @user.id, is_completed: false).order(:position).order(due_date: :asc).sort_by { |ti| ti.is_important ? 0 : 1 }
    @completed_todo_items = TodoItem.where(user_id: @user.id, is_completed: true).order(:position).order(due_date: :asc)
  end

  def show
  end

  def create
  end

  def edit
  end

  def update
  end

  def toggle_important
    todo_item = TodoItem.find_by(id: params[:id])

    if todo_item.update(is_important: !todo_item.is_important)
      render json: todo_item, status: 200
    else
      render json: {
        errors: todo_item.errors.full_messages,
        status: 422
      }
    end
  end

  def mark_completed
    todo_item = TodoItem.find_by(id: params[:id])

    if todo_item.update(is_completed: !todo_item.is_completed)
      render json: todo_item, status: 200
    else
      render json: {
        errors: todo_item.errors.full_messages,
        status: 422
      }
    end
  end

  def sort
    params[:todo_item].each_with_index do |id, index|
      TodoItem.where(id: id).update_all(position: index + 1)
    end

    head :ok
  end

  private

  def get_user(user_id)
    begin
      @user = User.find_or_create_by(line_id: user_id)
    rescue ActiveRecord::RecordNotUnique
      @user = User.find_by(line_id: user_id)
    end
  end
end
