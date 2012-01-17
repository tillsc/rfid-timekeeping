require 'pty'


start = Time.now
real_start = nil

@data = Hash.new() {|h,k| h[k] = []}
@incorrect_lines = 0

def self.process(line)
  puts line
  if line =~ /EPC: ([0-9]+) rssi=(-?[0-9]+) ant=([0-9]+)/
    @data[[$1, $3]] << $2.to_i
  else
    @incorrect_lines+= 1
  end
end

def self.output
  puts "***** Results:"
  @data.each do |(id, ant), rssis|
    puts " * Got #{id} on antenna #{ant} for #{rssis.size} times."
    puts "     Min: #{rssis.min}, Max: #{rssis.max}, Avg: #{rssis.inject(&:+).to_f / rssis.size}"
  end
  puts "Couldn't understand #{@incorrect_lines} lines."
end

cmd = ARGV.join(" ")
begin
  puts "***** Starting '#{cmd}'"
  PTY.spawn( cmd ) do |stdin, stdout, pid|
    begin
      puts "***** Ignoring the output for 5 seconds"
      stdin.each do |line|
        if Time.now - start > 5    
          if !real_start   
            real_start = Time.now
            puts "***** Collecting the output for 20 seconds"
          end
          self.process(line)
          if (Time.now - real_start > 20)
            self.output
            exit(0) 
          end
        end        
      end
    rescue Errno::EIO
      puts "Errno:EIO error, but this probably just means " +
            "that the process has finished giving output"
    end
  end
rescue PTY::ChildExited
  puts "The child process exited!"
end


