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
  #puts "Queue size: #{$queue.size}"
  'OK'
end

post '/kill' do
  $queue << params 
  #puts "Queue size: #{$queue.size}"
  'OK'
end


get '/status' do
  log = Logger.new($log_file)
  log.level = Logger::INFO

  $ovpn = nil
  status = nil
  $mutex.synchronize do
     begin
	log.info "OpenVPN execute GET /status"
        $ovpn = OpenvpnManagement.new :host => $ovpn_host, :port => $ovpn_port
        status = $ovpn.status
        $ovpn.destroy
      rescue Exception => msg
        log.info "OpenVPN not running at #{$ovpn_host}:#{$ovpn_port}... for GET /status"
        log.info msg
        if !$ovpn.nil?
            log.info "Destroy OpenVPN... for GET /status"
            $ovpn.destroy
        end
      end
    end
  if !status.nil?
    status.to_s
  end
end

consumer = Thread.new do
    log = Logger.new($log_file)
    log.level = Logger::INFO
    #log.info "Starting the worker - kill session...."
	
    loop do
      value = $queue.pop
      log.info "consumed #{value}"
      $ovpn = nil

      $mutex.synchronize do
        begin
          $ovpn = OpenvpnManagement.new :host => $ovpn_host, :port => $ovpn_port
          log.info $ovpn.kill :host => value[:host], :port => value[:port]
          $ovpn.destroy
        rescue Exception => msg
          log.info "OpenVPN not running at #{$ovpn_host}:#{$ovpn_port}... for PUT /kill"
	  log.info msg
          if !$ovpn.nil?
            log.info "Destroy OVPN... for PUT /kill"
            $ovpn.destroy
          end
        end
      end
    end
end

# demonize and write pidfile 

#Process.daemon(true,true) 
pid_file = "#{__FILE__}.pid" 
File.open(pid_file, 'w') { |f| f.write Process.pid } 



