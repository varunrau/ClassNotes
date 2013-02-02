class SplashController < ApplicationController

  def index
  end

  def search
    @params = params
    @lectures, @info, @url, @course, @semester = live_data(params)
  end

end
