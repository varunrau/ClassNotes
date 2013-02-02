ClassNotes::Application.routes.draw do
  post "search" => "spash#search", :as => "search"
  root :to => 'splash#index'
end
