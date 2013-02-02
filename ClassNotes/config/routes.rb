ClassNotes::Application.routes.draw do
  post "search" => "splash#search", :as => "search"
  root :to => 'splash#index'
end
