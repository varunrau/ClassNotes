class Lecture < ActiveRecord::Base
  attr_accessible :fri, :mon, :thu, :tue, :wed, :professor, :time, :title
  belongs_to :course
  has_many :documents

  public
  def gen_day_string
    return "" << (self.mon ? "M" : "") << (self.tue ? "Tu" : "") << (self.wed ? "W" : "") << (self.thu ? "Th" : "") << (self.fri ? "F" : "")
  end
end
