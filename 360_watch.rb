require 'open-uri'
require 'nokogiri'
require './slack.rb'

URL_360 = "https://360.lmlab.net/"
MD_QUOTE = "\\`\\`\\`\n"
def upcoming_schedules
  html, charset = open(URL_360) do |page|
   [page.read, page.charset]
  end

  doc = Nokogiri::HTML.parse(html, nil, charset)
  schedules = []
  doc.css(".events-right").each do |e|
    day,wd,time,title =  e.text.scan(/(\d+\/\d+) (.) (.) \n(.+)$/m).flatten
    title.gsub!(/\s/,"")
    schedules << [day,wd,time,title]
  end
  schedules
end

def occupied?(schedules)
  schedules.each do |s|
    day,wd,time,title = s
    if title !~ /店長募集中/
      return true
    end
  end
  false
end

def print_schedules(schedules)
  printed = "360高千穂の予約が入っています @koki-h\n"
  printed << MD_QUOTE 
  schedules.each do |s|
    day,wd,time,title = s
    printed << sprintf("%s %s %s %s\n",day,wd,time,title)
  end
  printed << MD_QUOTE 
  printed
end

s = upcoming_schedules
#s = [["3/16", "木", "朝", "店長募集中"], ["3/16", "木", "昼", "店長募集中"], ["3/16", "木", "夜", "店長募集中"]]
if occupied?(s)
  slack(print_schedules(s))
end
