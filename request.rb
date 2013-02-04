
# build search url from search parameters
def build_url(params)
  course = params[:course]

  # parse standard search
  if params[:course]
    dept, num = '', ''
    args = params[:course].split().collect() {|term| term.strip}

    if args.length > 1
      if args.last =~ /\d/
        dept = args[0...-1].join(' ')
        num = args.last
      else
        dept = args.join(' ')
      end
    elsif args.length == 1
      index = args.first =~ /\d/
        isnum = true if Float(args.first) rescue false
      if index == 0 and args.first.length >= 4 and isnum
        params[:ccn] = "%05d" % Integer(Float(args.first))

      elsif index
        if index == 1
          num = args.first
        else
          dept = args.first[0...index]
          num = args.first[index..-1]
        end
      else
        dept = args.first
      end
    end

    params[:dept] = dept
    params[:course_num] = num
  end

  # params[:dept].gsub! /\s/, '+'

  term    = 'p_term='     + params.fetch(:semester, '').strip
  deptname= 'p_deptname=' + 'Choose+a+Department+Name+--'
  classif = 'p_classif='  + '--+Choose+a+Course+Classification+--'
  presuf  = 'p_presuf='   + '--+Choose+a+Course+Prefix%2fSuffix+--'
  day     = 'p_day='      + params.fetch(:days, '').strip

  fields = [term, deptname, classif, presuf, day]
  url = 'https://osoc.berkeley.edu/OSOC/osoc?' + fields.join('&')
  puts url

  # dept = params[:dept].strip().upcase()
  # num = params[:course_num].strip().upcase()
  # if dept == '' and num == ''
  #   course = 'RESULTS'
  # else
  #   course = (dept + " " + num).strip()
  # end

  return url, course
end


# fetch html results from search
def get_search_html(url)
  # fetch html for base page
  doc = open(url).read()

  # fetch next result pages
  row = 101
  nextdoc = doc
  while nextdoc.include?('see next results')
    nextdoc = open(url + '&p_start_row=' + row.to_s()).read()
    doc += nextdoc
    row += 100
  end
  return doc
end


# split html lines into sections
def group_lines(doc, partition_string)
  partitions = []
  group = []
  doc.each_line do |line|
    if line.include?(partition_string)
      if not group.empty?
        partitions << group
        group = []
      end
      group << line
    else
      if not group.empty?
        group << line
      end
    end
  end
  partitions << group
  return partitions
end


# fetch live enrollment for a section
def schedule(ccn, section_info)
  numbers = []
  nums = []

  codes = {'FL' => '12D2', 'SP' => '13B4', 'SU' => '13C1'}

  base = 'https://telebears.berkeley.edu/enrollment-osoc/osc?_InField1=RESTRIC'
  ccn = '&_InField2=' + ccn
  sem = '&_InField3=' + codes[params[:semester]]
  url = base + ccn + sem
  doc = open(url).read()

  doc.each_line do |line|
    if line.include?('limit')
      a = line.scan(Regexp.new(/([0-9]+)/))
      nums += a[0] + a[1]
    end
  end

  nums += ['0']*4
  enrolled, limit, wait_list, wait_limit = nums.collect {|x| x.strip}
  section_info[:enrolled] = enrolled + '/' + limit
  section_info[:waitlist] = wait_list + '/' + wait_limit
  section_info[:open] = Integer(enrolled) < Integer(limit)
  section_info[:url] = url

  if doc.include?('Error')
    section_info[:enrolled] = 'see link'
    section_info[:waitlist] = 'N/A'
    section_info[:open] = true
  end

end


# execute search
def live_data(params)
  require 'thread/pool'
  require 'open-uri'

  url, course = build_url(params)
  html = get_search_html(url)

  partition_string = '<TABLE BORDER=0 CELLSPACING=2 CELLPADDING=0>'
  html_sections = group_lines(html, partition_string)

  # parse each section for relevant information
  sections = []
  info = {}
  ccn_regex = Regexp.new(/name="_InField2" value="([0-9]*)"/)
  sem_regex = Regexp.new(/name="_InField3" value="([0-9A-Z]*)/)
  html_sections.each do |section_lines|
    d = []
    lookup_ccn = -1
    section_lines.each do |line|
      if line.include?(':&#160;')
        raw = line.scan(Regexp.new(/>([^<]+)/))
        d << (raw[1][0] + ' ').split('&#')[0].split('&nbsp')[0].split.join(' ')
      end
      match = line.match(ccn_regex)
      if match
        lookup_ccn = match.captures[0]
      end
    end
    if lookup_ccn == -1
      next
    end
    sec = Hash.new
    name = d[0]
    sec = { course: name, title: d[1], location: d[2],
      instructor: d[3], status: d[4], ccn: d[5], units: d[6],
      final: d[7], restrictions:d[8], note: d[9],
      enrollment: d[10], lookup_ccn: lookup_ccn }
    if sec[:location].include? 'UNSCHED'
      time = 'UNSCHED'
      place = sec[:location].split('UNSCHED')[1].strip
    else
      time_place = sec[:location].split(',')*2
      time = time_place[0]
      place = time_place[1].split('(')[0].strip
    end
    if sec[:ccn].include?('SEE NOTE') or sec[:ccn].strip == '' or sec[:ccn].include?('SEE DEPT')
      sec[:ccn] = "%05d" % lookup_ccn
    end
    sec[:time] = time
    sec[:place] = place
    info[name] = sec
    sections << name
  end

  if sections.length > 60
    num_threads = 60
  elsif sections.length > 30
    num_threads = 30
  else
    num_threads = 15
  end

  # fetch live data for each section
  pool = Thread::Pool.new(num_threads)
  stats = Hash.new
  sections.each do |section|
    lookup_ccn = info[section][:lookup_ccn]
    pool.process {
      schedule(lookup_ccn, info[section])
    }
  end
  pool.shutdown

  # group by lecture
  lectures = []
  lec = []
  last_lec = ''
  lec_was_last = false
  sections.reverse.each do |name|
    if name.include?(' S ')
      if lec_was_last
        lectures << lec
        lec = []
      end
      lec.unshift(name)
      lec_was_last = false
      next
    end
    title = name.split[0...-3].join(' ')
    if not lec_was_last
      lec.unshift(name)
      lec_was_last = true
      last_lec = title
      next
    end
    if title == last_lec and lec.length > 1
      lec.unshift(name)
    else
      lectures << lec
      lec = [name]
    end
    lec_was_last = true
    last_lec = title
  end
  if lec.length > 0
    lectures << lec
  end
  lectures.reverse!

  return lectures, info, url, course, params[:semester]
end

maps = [
  {:days => "M", :semester => "SP"},
  {:days => "Tu", :semester => "SP"},
  {:days => "W", :semester => "SP"},
  {:days => "Th", :semester => "SP"},
  {:days => "F", :semester => "SP"},
  {:days => "MW", :semester => "SP"},
  {:days => "WF", :semester => "SP"},
  {:days => "MF", :semester => "SP"},
  {:days => "TuTh", :semester => "SP"},
  {:days => "MWF", :semester => "SP"},
  {:days => "MTWTF", :semester => "SP"}
]

maps.each { |map|
  @lectures, @info, @url, @course, @semester = live_data(map)
  puts @lectures
}
