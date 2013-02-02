class Lecture < ActiveRecord::Base
  attr_accessible :fri, :mon, :thu, :tue, :wed, :professor, :time, :title
  belongs_to :course
end
