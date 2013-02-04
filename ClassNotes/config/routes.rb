ClassNotes::Application.routes.draw do
  post "search" => "splash#search", :as => "search"
  post "documents" => "splash#documents", :as => "documents"
  post "open_document" => "splash#open_document", :as => "open_document"
  root :to => 'splash#index'
end
