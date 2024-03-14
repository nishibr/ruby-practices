# frozen_string_literal: true

require 'optparse'

def main
  options, files = parse_options
  options = { l: true, w: true, c: true } if options.empty?
  overall_words_count, standard_input_flag = process_words_count(files)
  column_width = calculate_column_width(options, overall_words_count, standard_input_flag)
  display_words_count(options, overall_words_count, column_width)
end

def parse_options
  opt = OptionParser.new
  options = {}
  opt.on('-l') { |v| options[:l] = v }
  opt.on('-w') { |v| options[:w] = v }
  opt.on('-c') { |v| options[:c] = v }
  files = opt.parse!(ARGV)
  [options, files]
end

def process_words_count(files)
  overall_words_count = []
  standard_input_flag = false
  if files.any?
    files.each do |file|
      text = File.read(file)
      input_words = words_count(text, file)
      overall_words_count.push(input_words)
    end
    overall_words_count.push(total_words_count(overall_words_count)) if files.size > 1
  else
    overall_words_count.push(words_count($stdin.read))
    standard_input_flag = true
  end
  [overall_words_count, standard_input_flag]
end

def words_count(text, file = '')
  result = {}
  result.store('lines', text.count("\n"))
  result.store('words', text.split(/\s+/).size)
  result.store('bytes', text.length)
  result.store('file', file)
  result
end

def total_words_count(counts)
  totals = {}
  totals.store('lines', counts.compact.sum { |count| count['lines'] })
  totals.store('words', counts.compact.sum { |count| count['words'] })
  totals.store('bytes', counts.compact.sum { |count| count['bytes'] })
  totals.store('file', 'total')
  totals
end

def calculate_column_width(options, overall_words_count, standard_input_flag)
  if options.length == 1
    0
  elsif standard_input_flag
    7
  else
    overall_words_count.map { |item| [item['lines'], item['words'], item['bytes']].compact.max }.max.to_s.length
  end
end

def display_words_count(options, overall_words_count, column_width)
  overall_words_count.each do |item|
    output = ''
    output += "#{item['lines'].to_s.rjust(column_width)} " if options[:l]
    output += "#{item['words'].to_s.rjust(column_width)} " if options[:w]
    output += "#{item['bytes'].to_s.rjust(column_width)} " if options[:c]
    output += item['file']
    puts output
  end
end

main
