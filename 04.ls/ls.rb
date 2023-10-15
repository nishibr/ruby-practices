# frozen_string_literal: true

NUMBER_OF_COL = 3
target_dir = '*'

def get_file_list(target_dir)
  Dir.glob(target_dir)
end

def output(file_list)
  number_of_row = (file_list.size / NUMBER_OF_COL.to_f).ceil
  number_of_row.times do |i|
    NUMBER_OF_COL.times do |j|
      print file_list[number_of_row * j + i].ljust(11) if !file_list[number_of_row * j + i].nil?
    end
    puts
  end
end

file_list = get_file_list(target_dir)
output(file_list)
