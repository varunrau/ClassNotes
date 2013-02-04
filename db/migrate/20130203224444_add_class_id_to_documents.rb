class AddClassIdToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :class_id, :integer
  end
end
