#!/usr/bin/ruby

require File.join(File.dirname(__FILE__), "../lib/reader")

require 'gnuplot'

begin
  
  cmd = Gnuplot.gnuplot(true) or raise 'gnuplot not found'
  @gpio = IO::popen(cmd, "w")

  @i = 0
  @reader = Reader.new(ARGV.join(" "), lambda { |line| 
    puts line
    @i+=1 
    @gpio << "plot x**#{@i}\n"
    
  }) do |rfid, ant, strength|
  end

  @reader.run
  
ensure
  @gpio.close
end