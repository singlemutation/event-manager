require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'
require 'time'

def clean_phone(num)
  num = num.tr('^0-9', '')
    if num.length == 10
      num
    elsif num.length == 11
      num.split(//).drop(1).join() if num.split(//)[0] == '1'
    else
      'bad number'
    end
end

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]
end

def most_common_value(a)
  a.group_by(&:itself).values.max_by(&:size).first
end

def busy_hour(time)
  time = Time.strptime(time, '%m/%d/%Y %k:%M').hour
end

def sort_hours(reg_date)
  reg_date = reg_date.reduce(Hash.new(0)) do |num, count|
    num[count] += 1
    num
  end
   reg_date.sort_by {|k, v| -v}.to_h
end

def regdate_to_regday(date)
  Date.strptime(date, '%m/%d/%Y').wday
end

def legislators_by_zipcode(zipcode)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
      address: zipcode,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
  ).officials
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

def save_thank_you_letter(id, form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

puts 'Event Manager Initialized!'

contents = CSV.open('event_attendees.csv', headers: true, header_converters: :symbol)

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter

reg_date = []
reg_day = []
contents.each do |row|
  id = row[0]
  name = row[:first_name]

  # zipcode = clean_zipcode(row[:zipcode])

  # legislators = legislators_by_zipcode(zipcode)

  # form_letter = erb_template.result(binding)

  # save_thank_you_letter(id, form_letter)

  # phone_number = clean_phone(row[:homephone])

  # reg_date.push busy_hour(row[:regdate])

  reg_day.push regdate_to_regday(row[:regdate])

end

p sort_hours(reg_day)
