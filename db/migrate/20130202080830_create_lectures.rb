class CreateLectures < ActiveRecord::Migration
  def change
    create_table :lectures do |t|
      t.boolean :mon
      t.boolean :tue
      t.boolean :wed
      t.boolean :thu
      t.boolean :fri

      t.timestamps
    end
  end
end
