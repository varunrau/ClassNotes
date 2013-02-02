class AddProfessorsAndTimesToLectures < ActiveRecord::Migration
  def change
    add_column :lectures, :professor, :string
    add_column :lectures, :time, :string
  end
end
