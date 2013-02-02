class SplashController < ApplicationController
  helper_method :gen_day_string

  def index
  end

  def search
    @lectures, @info, @url, @course, @semester = live_data(params)
    # This will return an array of booleans for class days for each lecture
    @classes, @days, @profs, @times = meetingTimesForLectures(@lectures, @info)
    @courses = Array.new
    @classes.length.times do |index|
      a_lecture = Lecture.find_all_by_title(@classes[index])
      if(a_lecture.kind_of?(Array))
        @courses.concat(a_lecture)
      else
        @courses << a_lecture
      end
    end
    # if @courses.length == 1
    #   redirect_to document_path
    # end
  end
end
