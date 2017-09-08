

def start_fake(host, port, use_ssl: false)
  reader, writer = IO.pipe

  # Fork off the fake server to minimize conflicts with the current process.
  # EventMachine has major stability issues when it has to exist with other
  # threads.
  pid = Process.fork
  if !pid
    # child proc
    reader.close
    # Turn off any output so it doesn't pollute test output
    $stdout.reopen('/dev/null')
    $stderr.reopen('/dev/null')
    server = FakeSignalFlow.new(host, port, writer)
    if use_ssl
      server.run_server_ssl
    else
      server.run_server
    end
    exit
  else
    # original proc
    writer.close
    server_pid = pid
    if !wait_for_port_to_open(host, port)
      fail 'Fake SignalFlow server failed to start!'
    end
  end

  # Kill it with INT to give it a chance to cleanup, if that matters
  [->(){
    Process.kill("INT", server_pid)
  }, reader]
end

def wait_for_port_to_open(ip, port)
  begin
    Timeout::timeout(5) do
      while true
        begin
          s = TCPSocket.new(ip, port)
          s.close
          return true
        rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
          sleep 0.1
        end
      end
    end
  rescue Timeout::Error
  end

  return false
end

def wait_for_notice(pipe, notice, timeout=3)
  Timeout::timeout(timeout) do
    while true
      out = pipe.gets
      next if out.nil?
      if out.start_with? notice
        return out.strip
      end
    end
  end
  fail "Did not receive notice #{notice} from server within #{timeout} seconds"
end
