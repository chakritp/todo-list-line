Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  post 'message_callback', to: 'todo_items#message_callback'
  get 'auth', to: 'application#auth'
  
  scope ':user_id' do
    resources :todo_items do
      collection do
        patch :sort
      end
      member do
        patch :toggle_important
        patch :mark_completed
      end
    end
  end
end
