Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  post 'message_callback', to: 'todo_items#message_callback'
  
  resources :todo_items do
    post 'mark_completed', to: 'todo_items#mark_completed'
  end
end
