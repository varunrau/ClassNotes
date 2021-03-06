class SplashController < ApplicationController
  helper_method :gen_day_string
  layout nil
  layout 'application', :except => :about

  def index
    # Login in to the master account
    drive = GoogleDrive.login("berkeleyclassnotes@gmail.com", "calnotes")
    session[:drive] = drive
    puts params
  end

  def search
    drive = session[:drive]
    puts 'hello world'
    file = drive.file_by_title("me.txt")
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
  end

  def documents
    puts params[:id]
    @documents = Document.find_all_by_class_id(params[:id])
  end

  def open_document
    doc_id = params[:id]
    doc = Document.find(doc_id)
    drive = session[:drive]
    lecture = Lecture.find(doc.class_id)
    unless doc.link
      template_doc = Rails.root.to_s + "/app/assets/documents/document.doc"
      drive.upload_from_file(template_doc, lecture.title + " " + doc.date, :convert => true)
      google_doc_file = drive.file_by_title(lecture.title + " " + doc.date)
      google_doc_file.acl.push(
        {:scope_type => "default",
          :with_key => true,
          :role => "writer"
      })
      doc.link = google_doc_file.human_url
      doc.save
    end
    redirect_to doc.link
  end

  def all_classes
    @courses = Lecture.all
  end

  def about
  end

end
