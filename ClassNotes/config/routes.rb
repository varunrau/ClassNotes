ClassNotes::Application.routes.draw do
  resources :spash
  root :to => 'splash#index'
end
