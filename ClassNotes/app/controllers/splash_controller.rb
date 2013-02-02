class SplashController < ApplicationController

  def index
  end

  def search
    @lectures, @info, @url, @course, @semester = live_data(params)
    # This will return an array of booleans for class days for each lecture
    @classes, @days, @profs, @times = meetingTimesForLectures(@lectures, @info)

    if @classes.length == 1
      redirect_to document
    end
  end

  def document

  end

end
