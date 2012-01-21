#!/usr/bin/ruby

require File.join(File.dirname(__FILE__), "../lib/reader")

require 'gnuplot'

XRANGE = 60000

@data = {}

def self.add_to_plot(now, rfid, strength)
  @data[rfid] ||= [[], []]
  @data[rfid][0] << now
  @data[rfid][1] << strength
end

def self.plot(now)
  @gpio << "set xrange [#{now - XRANGE}:#{now}]\n"
  @data.each do |rfid, data|
    if data[0].any? && data[0][0] < (now - XRANGE)
      data[0].shift
      data[1].shift
    end
  end
  @gpio << "plot " 
  @gpio << @data.keys.map { |rfid| 
      "'-' using 1:2 title '#{rfid}' with lines"
    }.join(",")
    @gpio << "\n"
  @data.each do |rfid, data|
    @gpio << data.to_gplot
    @gpio << "\n"
  end
end

begin

  cmd = Gnuplot.gnuplot(false) or raise 'gnuplot not found'
  @gpio = IO::popen(cmd, "w")

  @reader = Reader.new(ARGV.join(" ")) do |rfid, ant, strength|
    now = (Time.now.to_f * 1000).to_i % 86400000 # Milliseconds since midnight
    self.add_to_plot(now, rfid, strength)
    if (!@last_plot || now - @last_plot > 500)
      self.plot(now)
      @last_plot = now 
    end
  end
  
  @reader.line_callback = lambda do |line| 
    puts line
  end

  @reader.run

ensure
  @gpio.close
end

