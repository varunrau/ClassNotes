ClassNotes::Application.routes.draw do
  get "static_pages/home"

  get "static_pages/help"

  post "search" => "spash#search", :as => "search"
  root :to => 'splash#index'
end
