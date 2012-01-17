#!/usr/bin/ruby

require File.join(File.dirname(__FILE__), "../lib/reader")

@start = Time.now
@data = Hash.new() {|h,k| h[k] = []}
@incorrect_lines_before = 0

@reader = Reader.new(ARGV.join(" "), lambda { |line| 
  puts line
  if Time.now - @start > 5 
    if !@real_start
      @real_start = Time.now
      puts "***** Collecting the output for 20 seconds"
      @incorrect_lines_before = @reader.incorrect_lines
    end   
    if (Time.now - @real_start > 20)
      self.output
      exit(0) 
    end
    true
  end
  }) do |rfid, ant, strength|
    if @real_start   
      @data[[rfid, ant]] << strength
    end        
  end

  def self.output
    puts "***** Results:"
    @data.each do |(id, ant), rssis|
      puts " * Got #{id} on antenna #{ant} for #{rssis.size} times."
      puts "     Min: #{rssis.min}, Max: #{rssis.max}, Avg: #{rssis.inject(&:+).to_f / rssis.size}"
    end
    puts "Couldn't understand #{@reader.incorrect_lines - @incorrect_lines_before} lines."
  end

  @reader.run
