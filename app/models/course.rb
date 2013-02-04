class Course < ActiveRecord::Base
  attr_accessible :semester, :title, :year
  has_many :lectures
end
