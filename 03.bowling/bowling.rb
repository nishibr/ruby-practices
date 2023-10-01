#!/usr/bin/env ruby
# frozen_string_literal: true

class Bowling
  def make_frames
    score = ARGV[0]
    scores = score.split(',')
    shots = []
    scores.each do |s|
      if s == 'X'
        shots << 10 << 0
      else
        shots << s.to_i
      end
    end
    frames = []
    shots.each_slice(2) do |s|
      frames << s
    end
    calculate_point(frames)
  end

  private

  def calculate_point(frames)
    point = 0
    frames.each.with_index(1) do |frame, index|
      point += add_point(frames, frame, index)
    end
    puts point
  end

  def add_point(frames, frame, index)
    if frame[0] == 10 && index < 10
      if frames[index][0] == 10
        10 + 10 + frames[index + 1][0]
      else
        10 + frames[index].sum
      end
    elsif frame.sum == 10 && index < 10
      10 + frames[index][0]
    else
      frame.sum
    end
  end
end

output_bowling_score = Bowling.new
output_bowling_score.make_frames
