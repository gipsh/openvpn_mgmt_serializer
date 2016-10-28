require 'sinatra'
require 'thread'
require 'openvpn_management'
$ovpn_host = 'localhost'
$ovpn_port = 8888



queue = Queue.new

set :port, 9090

get '/kill' do
  queue << params 
  length = queue.size
  #printf 'QUEUE LENGTH %d', length
  'Message Received'
end

consumer = Thread.new do
    puts "Starting the worker...."
    ovpn = OpenvpnManagement.new :host => $ovpn_host, :port => $ovpn_port

    loop do
      value = queue.pop
      puts "consumed #{value}"
      puts ovpn.kill :host => value[:host], :port => value[:port]
    end
end



Process.daemon(true,true) 
pid_file = "#{__FILE__}.pid" 
File.open(pid_file, 'w') { |f| f.write Process.pid } 



