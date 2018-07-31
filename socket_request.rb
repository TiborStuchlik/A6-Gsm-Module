# example of socket request
require "./lib/a6"

@a6 = Lib::A6.new(3)

def init_modem
  puts @a6.at.to_s
  puts @a6.info.to_s
  puts @a6.default.to_s
  puts @a6.signal.to_s
end

def connect_network
  puts @a6.packet_service(:detach).to_s
  puts @a6.packet_service(:attach).to_s
  puts @a6.define_pdp( 1, "IP", "internet").to_s
  puts @a6.activate_pdp( :activate, 1).to_s
  puts @a6.local_ip.to_s
end

def disconnect_network
  puts @a6.activate_pdp( :deactivate, 1).to_s
end

def conect_server
  puts @a6.start_tcp( "90.177.19.196", 888).to_s
end

def disconnect_server
  puts @a6.close_tcp.to_s
  #puts @a6.shut_tcp.to_s
  puts @a6.status.to_s
end

def init_connection
  init_modem
  disconnect_network
  connect_network
end

def send_data(data)
  puts @a6.send.to_s
  @a6.write( data)
  puts @a6.send_end.to_s
end

begin
  init_connection
  conect_server
  send_data("AB")
  disconnect_server
  disconnect_network

rescue => err
  puts err
end

@a6.close

