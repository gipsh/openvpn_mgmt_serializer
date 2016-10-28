# openvpn_mgmt_serializer
Serialize telnet sessions for openvpn management interface


1. configure the `$ovpn_host` and `$ovpen_port` management interface data.


2. just run the script
```
ruby tser.rb
```


3. to test just do this
```
wget "http://localhost:9090/kill?host=10.10.1.20&port=1010"
```


