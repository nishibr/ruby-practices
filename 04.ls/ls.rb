# frozen_string_literal: true

COLUMN_LENGTH = 3
FILE_SPACE = 2
TARGET_DIR = '*'

def fetch_files
  Dir.glob(TARGET_DIR)
end

def calculate_max_file_space(files)
  files.map(&:size).max + FILE_SPACE
end

def output(files)
  max_file_space = calculate_max_file_space(files)
  number_of_row = (files.size / COLUMN_LENGTH.to_f).ceil
  number_of_row.times do |i|
    COLUMN_LENGTH.times do |j|
      print files[number_of_row * j + i].ljust(max_file_space) if !files[number_of_row * j + i].nil?
    end
    puts
  end
end

files = fetch_files
output(files)
