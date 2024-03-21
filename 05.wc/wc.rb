# frozen_string_literal: true

require 'optparse'

def main
  options, files = parse_options
  options = { l: true, w: true, c: true } if options.empty?
  overall_analyzed_input = process_analyze_input(files)
  column_width = calculate_column_width(options, files, overall_analyzed_input)
  display_analyze_input(options, overall_analyzed_input, column_width)
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

def process_analyze_input(files)
  overall_analyzed_input = []
  if files.any?
    overall_analyzed_input = files.map { |file| analyze_input(File.read(file), file) }
    overall_analyzed_input.push(total_analyze_input(overall_analyzed_input)) if files.size > 1
  else
    overall_analyzed_input.push(analyze_input($stdin.read))
  end
  overall_analyzed_input
end

def analyze_input(text, file = '')
  result = {
    lines: text.count("\n"),
    words: text.split(/\s+/).size,
    bytes: text.length,
    file: file
  }
end

def total_analyze_input(overall_analyzed_input)
  totals = %i[lines words bytes].map { |key| [key, overall_analyzed_input.compact.sum { |input_analysis| input_analysis[key] || 0 }] }.to_h
  totals[:file] = 'total'
  totals
end

def calculate_column_width(options, files, overall_analyzed_input)
  if options.length == 1
    0
  elsif files.none?
    7
  else
    overall_analyzed_input.map { |item| [item[:lines], item[:words], item[:bytes]].compact.max }.max.to_s.length
  end
end

def display_analyze_input(options, overall_analyzed_input, column_width)
  overall_analyzed_input.each do |item|
    output = ''
    output += "#{item[:lines].to_s.rjust(column_width)} " if options[:l]
    output += "#{item[:words].to_s.rjust(column_width)} " if options[:w]
    output += "#{item[:bytes].to_s.rjust(column_width)} " if options[:c]
    output += item[:file]
    puts output
  end
end

main
