ClassNotes::Application.routes.draw do
  post "search" => "splash#search", :as => "search"
  get "document" => "splash#document", :as => "document"
  root :to => 'splash#index'
end
