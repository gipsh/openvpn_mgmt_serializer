require 'sinatra'
require 'thread'
require 'openvpn_management'
require 'logger'

$ovpn_host = 'localhost'
$ovpn_port = 8888

# sinatra settings
set :bind, '0.0.0.0'
set :port, 9090

queue = Queue.new

get '/kill' do
  queue << params 
  puts "Queue size: #{queue.size}"
  'OK'
end

consumer = Thread.new do
    puts "Starting the worker...."
    log = Logger.new('tser.log')
    log.level = Logger::INFO

    loop do
      value = queue.pop
      log.info "consumed #{value}"

      begin
        ovpn = OpenvpnManagement.new :host => $ovpn_host, :port => $ovpn_port
        log.info ovpn.kill :host => value[:host], :port => value[:port]
        ovpn.destroy
      rescue
	log.info "OpenVPN not running at #{$ovpn_host}:#{$ovpn_port}..."
      end
    end
end

# demonize and write pidfile 

#Process.daemon(true,true) 
pid_file = "#{__FILE__}.pid" 
File.open(pid_file, 'w') { |f| f.write Process.pid } 



