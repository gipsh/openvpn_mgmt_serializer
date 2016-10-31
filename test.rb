require 'httparty'

100.times do |n|

 host = Array.new(4){rand(256)}.join('.') 
 port = rand(1024)+1024
 response = HTTParty.get("http://localhost:9090/kill?host=#{host}&port=#{port}")
 

end




