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

    reply_text = 
    begin
      case message_text
      when 'edit'
        "You Selected Edit"
      when 'list'
        "You Selected List"
      when /\s*(:)\s*/
        p message_text.split(/\s*(:)\s*/).inspect
        task = message_text.split(/\s*(:)\s*/, 3)[0]
        date = message_text.split(/\s*(:)\s*/, 3)[2]
        time = message_text.split(/\s*(:)\s*/, 3)[4]

        puts "task: #{task}"
        puts "date: #{date}"
        puts "time: #{time}"
        
        raise if task.nil? || date.nil? 

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

        "Task: #{task}, Due Date: #{date_time.inspect}"
      else
        raise
      end
    rescue Exception => e
      Rails.logger.debug e.inspect
      "Sorry but that's an invalid option. Please ensure the format is correct."
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
  end

  def show
  end

  def create
  end

  def edit
  end

  def update
  end

  def mark_completed
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
