require 'sinatra'
require 'thread'
require 'openvpn_management'
require 'logger'

$ovpn_host = 'localhost'
$ovpn_port = 8888

$log_file = 'tser.log'

# sinatra settings
set :bind, '0.0.0.0'
set :port, 9090


$queue = Queue.new
$ovpn = nil
$mutex = Mutex.new

get '/kill' do
  $queue << params 
  puts "Queue size: #{$queue.size}"
  'OK'
end

post '/kill' do
  $queue << params 
  puts "Queue size: #{$queue.size}"
  'OK'
end


get '/status' do
 
  status = nil
  $mutex.synchronize do
     begin
        $ovpn = OpenvpnManagement.new :host => $ovpn_host, :port => $ovpn_port
        status = $ovpn.status
	puts status
        $ovpn.destroy
      rescue
        puts "OpenVPN not running at #{$ovpn_host}:#{$ovpn_port}..."
      end
    end
  status
end

consumer = Thread.new do
    puts "Starting the worker...."
    log = Logger.new($log_file)
    log.level = Logger::INFO

    loop do
      value = $queue.pop
      log.info "consumed #{value}"

      $mutex.synchronize do
        begin
          $ovpn = OpenvpnManagement.new :host => $ovpn_host, :port => $ovpn_port
          log.info $ovpn.kill :host => value[:host], :port => value[:port]
          $ovpn.destroy
        rescue
    	  log.info "OpenVPN not running at #{$ovpn_host}:#{$ovpn_port}..."
        end
      end

    end
end

# demonize and write pidfile 

#Process.daemon(true,true) 
pid_file = "#{__FILE__}.pid" 
File.open(pid_file, 'w') { |f| f.write Process.pid } 



