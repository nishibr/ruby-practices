# frozen_string_literal: true

require 'optparse'

COLUMN_LENGTH = 3 # 出力する列数
FILE_SPACE = 2    # 出力時の余白
TARGET_DIR = '*'  # 対象ディレクトリ

def main
  options = set_options
  files = fetch_files(options)
  display_files(files)
end

# オプションを設定する
def set_options
  received_options = ARGV.getopts('a')
  received_options['a'] ? File::FNM_DOTMATCH : 0
end

# ファイル一覧を取得する
def fetch_files(options)
  Dir.glob(TARGET_DIR, options)
end

# ファイル一覧を表示する
def display_files(files)
  sorted_files = sort_files(files)
  column_widths = calculate_column_widths(sorted_files)
  sorted_files.each_slice(COLUMN_LENGTH) do |sorted_files_slice|
    sorted_files_slice.each_with_index do |file, index|
      print file.ljust(column_widths[index] + FILE_SPACE)
    end
    puts
  end
end

# ファイル一覧を出力順に並べ替える
def sort_files(files)
  number_of_row = (files.size / COLUMN_LENGTH.to_f).ceil
  sorted_files = []
  number_of_row.times do |i|
    COLUMN_LENGTH.times do |j|
      sorted_files.push(files[number_of_row * j + i] || '')
    end
  end
  sorted_files
end

# 各列ごとの最大幅を計算する
def calculate_column_widths(sorted_files)
  column_widths = Array.new(COLUMN_LENGTH, 0)
  sorted_files.each_slice(COLUMN_LENGTH) do |sorted_files_slice|
    sorted_files_slice.each_with_index do |file, index|
      column_widths[index] = [column_widths[index], file.length].max
    end
  end
  column_widths
end

main
