class SplashController < ApplicationController
  helper_method :gen_day_string

  def index
    # Login in to the master account
    drive = GoogleDrive.login("berkeleyclassnotes@gmail.com", "calnotes")
    session[:drive] = drive
    puts params
  end

  def search
    drive = session[:drive]
    puts 'hello world'
    drive.files.each do |file|
      file.acl.push(
        {:scope_type => "default",
          :with_key => true,
          :role => "writer"
      })
      puts file.title
      puts file.human_url
    end
    file = drive.file_by_title("me.txt")
    puts 'hello world'
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
