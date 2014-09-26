#!/usr/bin/env ruby

require 'csv'

require 'nokogiri'
require 'open-uri'

# Base URL for relative team links

base_url = "http://www.owgr.com"

url = "http://www.owgr.com/en/Ranking.aspx?pageNo=1&pageSize=6208&country=All"

rankings = CSV.open("csv/rankings.csv","w",{:col_sep => "\t"})

# Header for rankings

header = ["this_week", "last_week", "end_2013", "country", "flag_url", "name", "player_url", "avg_points", "total_points", "event_played_divisor", "points_lost", "points_gained", "events_played_actual"]

rankings << header

table_xpath = '//section[@id="ranking_table"]/div/table/tr'

page = Nokogiri::HTML(open(url))

players = 0

page.xpath(table_xpath).each do |player|

  players += 1

  row = []
  player.xpath("td").each do |td|

    case (td.attr("class"))
    when "name"
      player_name = td.text.strip rescue nil
      print "#{player_name}\n"
      player_url = td.search("a").first.attributes["href"].text.strip rescue nil
      row << td.text.strip rescue nil
      row << (base_url+player_url rescue nil)
    when "ctry"
      flag_a = td.search("img").first
      flag_name = flag_a.attr("alt").strip rescue nil
      flag_url = flag_a.attr("src").strip rescue nil
      row << flag_name
      row << (base_url+flag_url rescue nil)
    else
      row << td.text.strip rescue nil
    end
  
  end

  rankings << row
  rankings.flush

end

rankings.close

print "\nFound #{players} players\n"
