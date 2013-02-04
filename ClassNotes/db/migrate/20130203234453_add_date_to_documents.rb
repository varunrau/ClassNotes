class AddDateToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :date, :string
  end
end
