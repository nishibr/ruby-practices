require 'date'
require 'optparse'

class Calendar
  def print_calendar
    params = ARGV.getopts("", "y:#{Date.today.year}", "m:#{Date.today.month}")
    target_year = params["y"].to_i  # 表示する年
    target_month = params["m"].to_i  # 表示する月
    first_date = Date.new(target_year, target_month, 1) # 月初
    last_date = Date.new(target_year, target_month, -1)  # 月末
    output_calendar(first_date, last_date)
  end

  private

  def output_calendar(first_date, last_date)
    puts first_date.strftime("%m月 %Y").center(20)
    puts "日 月 火 水 木 金 土"
    (first_date..last_date).each do |date|
      day = date.day.to_s.rjust(2)
      if date == first_date
        first_date.wday.times do
          print "   "
        end
      end
      if date == Date.today
        print "\e[7m#{day}\e[0m "
      else
        print "#{day} "
      end
      puts if date.saturday?
    end
    print "\n\n"
  end
end

output_calendar = Calendar.new
output_calendar.print_calendar
