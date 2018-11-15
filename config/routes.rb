Rails.application.routes.draw do
  root to: 'pages#home'

  get 'infocamara', to: "pages#infocamara"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :councillors, only: [:index, :show]
  resources :projects, only: [:index, :show]
end
