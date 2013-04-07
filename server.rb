require_relative 'models/server'

require 'socket'
require 'colorize'

server = TCPServer.open(7269)
@server = Server.new
id = 0

puts "[info] Server started on ip #{Socket.ip_address_list.detect{|iface| iface.ipv4_private?}.ip_address} with port 7269"
loop do
  Thread.start(server.accept) do |client|
    begin
      client = {
        :socket => client,
        :id => id += 1,
        :ip => client.peeraddr.last
      }
      @server.clients << client

      puts "[info] Client ##{client[:id]} from #{client[:ip]} connects"

      while line = client[:socket].gets.strip;
        command = line.split(' ')
        puts "[info] Client ##{client[:id]} from #{client[:ip]} gives command `#{line}`"

        if !client[:name] 
          if command.first == Protocol::GREET
            name = command[1]
            raise 'The given name is already in use' if @server.clients.map{|c| c[:name]}.include?(name)

            client[:name]      = command[1]
            client[:chat]      = command[2] == Protocol::TRUE
            client[:challenge] = command[3] == Protocol::TRUE
            client[:socket].puts "#{Protocol::GREET} #{Protocol::TRUE} #{Protocol::TRUE}"

            @server.push_lists
          else
            raise 'You first need to introduce yourself to the server to continue -- `greet NAME`'
          end
        else
          if command.first == Protocol::JOIN
            @server.join(client, command[1].to_i)
          elsif command.first == Protocol::PLACE
            @server.place(client, command[1], command[2].to_i, command[3].to_i)
          elsif command.first == Protocol::CHAT
            @server.chat(client, line)
          elsif command.first == Protocol::CHALLENGE
            @server.challenge(client, line)
          elsif command.first == Protocol::CHALLENGE_RESPONSE
            @server.challenge_response(client, command[1])
          else
            raise 'The given command is not supported, refer to the protocol for the correct syntax'
          end
        end
      end
    rescue Exception => e
      puts "[exception] Client ##{client[:id]} from #{client[:ip]}: #{e.message}".red
      puts e.backtrace.join("\n").yellow

      client[:socket].puts "#{Protocol::ERROR} #{e.message}"
    ensure
      puts "[info] Client ##{client[:id]} from #{client[:ip]} disconnects"

      @server.remove_client(client)

      client[:socket].close
    end
  end
end
