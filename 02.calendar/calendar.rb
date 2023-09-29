require 'date'
require 'optparse'
require 'paint'

class Calendar
  def decide_month
    ### コマンドラインオプションを受け取り、表示する月を決める
    # オプションの指定がなければ、デフォルト値(現在日付)を使用する
    params = ARGV.getopts("", "y:#{Date.today.year}", "m:#{Date.today.month}")
    target_year = params["y"].to_i  # 表示する年
    target_month = params["m"].to_i  # 表示する月
    first_day = Date.new(target_year, target_month, 1) # 月初
    last_day = Date.new(target_year, target_month, -1)  # 月末
    output_calendar(target_year, target_month, first_day, last_day)
  end

  private

  def output_calendar(target_year, target_month, first_day, last_day)
    # 月、西暦を中央揃えで出力する
    puts first_day.strftime("%m月 %Y").center(20)
    # 日~土を出力する
    puts "日 月 火 水 木 金 土"
    # 日にちを出力する
    (1..last_day.day).each do |day|
      each_day = Date.new(target_year, target_month, day)
      # 1日の場合は曜日に対応した空白を出力する
      if day == 1
        first_day.wday.times do
          print "   "
        end
      end
      # 今日の日付の場合は色を反転して出力する
      if Date.today == each_day
        if day < 10
          print " "
        end
        paint_day = Paint[day, :inverse]
        printf("#{paint_day} ")
      else
        # 2桁右詰め + 半角スペース + 日にち で出力する
        printf("%2d ", day)
      end
      # 土曜の場合は改行する
      if each_day.saturday?
        print "\n"
      end
    end
    # 日にち出力後改行する
    print "\n"
  end
end

output_calendar = Calendar.new
output_calendar.decide_month
