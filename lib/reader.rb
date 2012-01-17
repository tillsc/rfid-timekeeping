require 'pty'

class Reader

  attr_reader :incorrect_lines

  def initialize(cmd, line_callback = nil, &block)
    @cmd = cmd
    @line_callback = line_callback
    @callback = block
    @incorrect_lines = 0
  end

  def run
    begin
      puts "***** Starting '#{@cmd}'"
      PTY.spawn(@cmd) do |stdin, stdout, pid|
        stdin.each do |line|
          
          if !@line_callback || @line_callback.call(line) 
          
            if line =~ /EPC: ([0-9]+) rssi=(-?[0-9]+) ant=([0-9]+)/
              @callback.call($1.to_i, $3.to_i, $2.to_i)
            else
              @incorrect_lines+= 1
            end
          
          end
        
        end
      end
    rescue Errno::EIO => e
      puts "Errno:EIO: Reader closed output!"
      puts e.backtrace.join("\n")
    rescue PTY::ChildExited => e
      puts "PTY::ChildExited: The child process exited!"
      puts e.backtrace.join("\n")
    end
  end

end
