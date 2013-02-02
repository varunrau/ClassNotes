class SplashController < ApplicationController
  helper_method :gen_day_string
  require 'google/api_client'
  ## Email of the Service Account #
  SERVICE_ACCOUNT_EMAIL = '354973612555@developer.gserviceaccount.com'

  ## Path to the Service Account's Private Key file #
  SERVICE_ACCOUNT_PKCS12_FILE_PATH = Rails.root.to_s + '/app/assets/privatekey/a34ffacc5aead4cb09dc5db89b79087a770bed18-privatekey.p12'

  def index
    key = Google::APIClient::PKCS12.load_key(SERVICE_ACCOUNT_PKCS12_FILE_PATH, 'notasecret')
    asserter = Google::APIClient::JWTAsserter.new(SERVICE_ACCOUNT_EMAIL,
        'https://www.googleapis.com/auth/drive', key)
    client = Google::APIClient.new
    client.authorization = asserter.authorize()
    drive = client.discovered_api('drive', 'v2')
    file = drive.files.insert.request_schema.new({
      'title' => 'My document',
      'description' => 'A test document',
      'mimeType' => 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
    })

    media = Google::APIClient::UploadIO.new(Rails.root.to_s + '/app/assets/documents/document.doc', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document')
    result = client.execute(
      :api_method => drive.files.insert,
      :body_object => file,
      :media => media,
      :parameters => {
      'uploadType' => 'multipart',
      'alt' => 'json'}
    )

    puts '==========='
    puts result
    puts '==========='
    jj result.data.to_hash

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
