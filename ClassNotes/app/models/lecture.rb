class Lecture < ActiveRecord::Base
  attr_accessible :fri, :mon, :thu, :tue, :wed, :professor, :time, :title
  belongs_to :course
  has_many :documents
end
