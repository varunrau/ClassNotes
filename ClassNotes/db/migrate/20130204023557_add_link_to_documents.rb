class AddLinkToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :link, :string
  end
end
