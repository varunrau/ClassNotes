class CreateCourses < ActiveRecord::Migration
  def change
    create_table :courses do |t|
      t.string :title
      t.string :semester
      t.string :year

      t.timestamps
    end
  end
end
