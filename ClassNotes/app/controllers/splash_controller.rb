class SplashController < ApplicationController

  def index
  end

  def search
    @lectures, @info, @url, @course, @semester = live_data(params)
    # This will return an array of booleans for class days for each lecture
    @meeting_times = meetingTimesForLectures(@lectures, @info)

  end

end
