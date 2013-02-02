class Lecture < ActiveRecord::Base
  attr_accessible :fri, :mon, :thu, :tue, :wed
  belongs_to :course
end
