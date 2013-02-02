class SplashController < ApplicationController

  def index
  end

  def search
    lectures, info, url, course, semester = live_data(params)
    meeting_times = meetingTimesForLectures(lectures, info)
  end

end
