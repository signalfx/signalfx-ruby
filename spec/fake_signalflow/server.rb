require 'faye/websocket'
require 'json'
require 'thin'
require 'thread'
require 'eventmachine'

require_relative './ssl'
require_relative './responses'


# Messages that are sent through the pipe to tell clients when the server is
# done processing messages.  It does not guarantee that the client has received
# the messages
AUTH_DONE_MESSAGE = "AUTH DONE"
EXECUTE_DONE_MESSAGE = "EXECUTE DONE"
PREFLIGHT_DONE_MESSAGE = "PREFLIGHT DONE"
ABORT_DONE_MESSAGE = "ABORT DONE"

class FakeSignalFlow
  def initialize(host, port, pipe)
    @host = host
    @port = port
    @pipe = pipe
  end

  def run_server(cert=nil)
    Faye::WebSocket.load_adapter('thin')
    thin = Rack::Handler.get('thin')

    thin.run(lambda do |env|
      # This is also capable of serving SSE responses in case we expand the
      # client to support HTTP-only.
      ws = Faye::WebSocket.new(env)

      ws.on :open do |e|
        puts "CONNECTED TO FAKE"
      end

      ws.on :message do |event|
        begin
          puts "FAKE GOT MESSAGE #{event.data}"
          msg = JSON.parse(event.data, {:symbolize_names => true})

          if msg[:type] == "authenticate"
            if AUTH.has_key? msg[:token]
              ws.send(AUTH.fetch(msg[:token]))
            else
              ws.close(4401, "Invalid authentication token: invalid token")
            end
            @pipe.puts AUTH_DONE_MESSAGE
          elsif ["execute", "preflight"].include? msg[:type]
            (msg[:type] == "execute" ? EXECUTE : PREFLIGHT).fetch(msg[:program]).each do |resp|
              begin
                ws.send(b64_resp_to_bin_array(resp, msg[:channel]))
              rescue Exception
                ws.send(resp)
              end
            end
            @pipe.puts (msg[:type] == "execute" ?
                        EXECUTE_DONE_MESSAGE :
                        PREFLIGHT_DONE_MESSAGE)
          elsif msg[:type] == "stop"
            ws.send(ABORT)
            @pipe.puts ABORT_DONE_MESSAGE
          end
        rescue Exception => e
          puts "Error handling request #{event.data}: #{e}"
        end
      end

      ws.on :close do |event|
        puts "CONNECTION ON FAKE SF CLOSED #{event.code} #{event.reason}"
      end

      ws.on :error do |e|
        puts "FAKE SERVER ERROR #{e.inspect}"
      end

      ws.rack_response
    end, :Host => @host, :Port => @port) do |server|
      if cert
        server.ssl_options = {
          :cert_chain_file  => cert.cert_path,
          :private_key_file => cert.key_path,
        }
        server.ssl = true
      end
    end
  end

  def run_server_ssl
    cert = SelfSignedCertificate.new
    begin
      run_server(cert)
    ensure
      cert.unlink_files
    end
  end

end
