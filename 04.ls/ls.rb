# frozen_string_literal: true

require 'optparse'
require 'etc'

COLUMN_LENGTH = 3 # 出力する列数
FILE_SPACE = 2    # 出力時の余白
TARGET_DIR = '*'  # 対象ディレクトリ
FILE_TYPE = {
  '01' => 'p',
  '02' => 'c',
  '04' => 'd',
  '06' => 'b',
  '10' => '-',
  '12' => 'l',
  '14' => 's'
}.freeze
FILE_MODE = {
  '0' => '---',
  '1' => '--x',
  '2' => '-w-',
  '3' => '-wx',
  '4' => 'r--',
  '5' => 'r-x',
  '6' => 'rw-',
  '7' => 'rwx'
}.freeze

def main
  options = ARGV.getopts('a', 'r', 'l')
  files = fetch_files(options)
  files.reverse! if options['r']
  options['l'] ? display_long_format(files) : display_short_format(files)
end

# ファイル一覧を取得する
def fetch_files(options)
  options['a'] ? Dir.glob(TARGET_DIR, File::FNM_DOTMATCH) : Dir.glob(TARGET_DIR)
end

# 表示する(ショートフォーマット)
def display_short_format(files)
  sorted_files = sort_files(files)
  short_format_column_widths = calculate_short_format_column_widths(sorted_files)
  sorted_files.each_slice(COLUMN_LENGTH) do |sorted_files_slice|
    sorted_files_slice.each_with_index do |file, index|
      print file.ljust(short_format_column_widths[index] + FILE_SPACE)
    end
    puts
  end
end

# 出力順に並べ替える(ショートフォーマット)
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

# 最大幅を計算する(ショートフォーマット)
def calculate_short_format_column_widths(sorted_files)
  short_format_column_widths = Array.new(COLUMN_LENGTH, 0)
  sorted_files.each_slice(COLUMN_LENGTH) do |sorted_files_slice|
    sorted_files_slice.each_with_index do |file, index|
      short_format_column_widths[index] = [short_format_column_widths[index], file.length].max
    end
  end
  short_format_column_widths
end

# 表示する(ロングフォーマット)
def display_long_format(files)
  formatted_files = files.map { |file| generate_long_format(file) }
  long_format_column_widths = calculate_long_format_column_widths(formatted_files)
  total_blocks = formatted_files.sum { |formatted_file| formatted_file[:blocks] } / 2
  puts "total #{total_blocks}"
  formatted_files.each do |formatted_file|
    puts "#{formatted_file[:type]}#{formatted_file[:mode]} "\
         "#{formatted_file[:nlink].rjust(long_format_column_widths[:nlink])} "\
         "#{formatted_file[:username].ljust(long_format_column_widths[:username])} "\
         "#{formatted_file[:groupname].ljust(long_format_column_widths[:groupname])} "\
         "#{formatted_file[:bitesize].rjust(long_format_column_widths[:bitesize])} "\
         "#{formatted_file[:mtime]} "\
         "#{formatted_file[:filename]}"
  end
end

# 生成する(ロングフォーマット)
def generate_long_format(file)
  fs = File.lstat(file)
  file_mode_number = fs.mode.to_s(8).rjust(6, '0')
  type = FILE_TYPE[file_mode_number[0..1]]
  long_format = {
    type:,
    mode: [3, 4, 5].map { |index| FILE_MODE[file_mode_number[index]] }.join,
    nlink: fs.nlink.to_s,
    username: Etc.getpwuid(fs.uid).name,
    groupname: Etc.getgrgid(fs.gid).name,
    bitesize: fs.size.to_s,
    mtime: fs.mtime.strftime('%b %d %H:%M'),
    filename: type == 'l' ? "#{file} -> #{File.readlink(file)}" : file,
    blocks: fs.blocks
  }
  set_special_permission(file_mode_number, long_format[:mode])
  long_format
end

# 特殊な権限を設定する(ロングフォーマット)
def set_special_permission(file_mode_number, long_format_mode)
  case file_mode_number[2]
  when '1'
    long_format_mode[8] = (long_format_mode[8] == 'x' ? 't' : 'T')
  when '2'
    long_format_mode[5] = (long_format_mode[5] == 'x' ? 's' : 'S')
  when '4'
    long_format_mode[2] = (long_format_mode[2] == 'x' ? 's' : 'S')
  end
end

# 最大幅を計算する(ロングフォーマット)
def calculate_long_format_column_widths(formatted_files)
  column_widths_attributes = %i[nlink username groupname bitesize]
  column_widths_attributes.map do |column_widths_attribute|
    [column_widths_attribute, formatted_files.map { |file| file[column_widths_attribute].to_s.length }.max]
  end.to_h
end

main
