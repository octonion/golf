#!/usr/bin/ruby1.9.3
# -*- coding: utf-8 -*-

require "csv"
require "mechanize"
require "json"

agent = Mechanize.new{ |agent| agent.history.max_size=0 }
agent.user_agent = "Mozilla/5.0"

results = CSV.open("tournaments.csv","w")

sb_url = "http://www.pgatour.com/r/schedule/"

bad = " "
bad2 = "�"

tries = 0
begin
  page = agent.get(sb_url)
rescue
  print " -> attempt #{tries}\n"
  tries += 1
  retry if (tries<4)
  #next
end

#path = "//*[@id='tourContent']/div[4]/div[6]/table/tbody/tr[2]/td[2]/a"
path = "//*[@id='tourContent']/div/div/table/tr" #/td" #[2]/a"

page.parser.xpath(path).each_with_index do |tr,i|

  if (i==0)
    next
  end

  row = []

  tr.xpath("td").each_with_index do |td,j|

    if (j==1)

      outer = td.text.split(/\n/,2)[0].strip
      outer2 = td.xpath("text()")[0].text.strip

      t = td.xpath("a").first
      if (t==nil)
        row += [nil,outer2]
      else
        row += [t["href"],t.inner_text.strip]
      end
    else
      t = td.inner_text.gsub(bad,"")
      t.gsub!(bad2,"")
      t.gsub!(/\t/,"")
      t.gsub!(/\n/,"")
      if (j==4)
        row += [t.strip!.gsub(",","").to_i]
      else
        row += [t.strip!]
      end
    end

  end

  if not(row[0]==nil)
    results << row[0..-2]
  end

end

results.close
