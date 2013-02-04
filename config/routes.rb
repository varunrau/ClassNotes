ClassNotes::Application.routes.draw do
  post "search" => "splash#search", :as => "search"
  post "documents" => "splash#documents", :as => "documents"
  post "open_document" => "splash#open_document", :as => "open_document"
  get "all" => "splash#all_classes", :as => "all_classes"
  get "about" => "splash#about", :as => "about"
  root :to => 'splash#index'
end
