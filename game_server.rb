require_relative 'models/server'
require 'socket'
require 'colorize'

GREET = 'greet'
JOIN  = 'join'
PLACE = 'place'
ERROR = 'error'
CHAT = 'chat'
TRUES = '1'

server = TCPServer.open(7269)
@clients = []
@server = Server.new(@clients)
id = 0

puts "[info] Server started on port 7269"
loop do
  Thread.start(server.accept) do |client|
    begin
      client = {
        :socket => client,
        :id => id += 1,
        :ip => client.peeraddr[3]
      }
      @clients << client

      puts "[info] Client ##{client[:id]} from #{client[:ip]} connects"

      while line = client[:socket].gets.strip;
        command = line.split(' ')
        puts "[info] Client ##{client[:id]} from #{client[:ip]} gives command `#{line}`"

        if !client[:name] 
          if command.first == GREET
            name = command[1]
            raise 'The given name is already in use' if @clients.map{|c| c[:name]}.include?(name)

            client[:name]      = command[1]
            client[:chat]      = command[2] == TRUES
            client[:challenge] = command[3] == TRUES
            client[:socket].puts "#{GREET} 1 0"

            @server.update_lobby_chat_list
          else
            raise 'You first need to introduce yourself to the server to continue -- `greet NAME`'
          end
        else
          if command.first == JOIN
            @server.join(client, command[1].to_i)
          elsif command.first == PLACE
            @server.place(client, command[1].to_i, command[2].to_i, command[3])
          elsif command.first == CHAT
            @server.chat(client, line)
          elsif command.first == CHALLENGE
            @server.challenge(client, line)
          elsif command.first == CHALLENGE_RESPONSE
            @server.challenge_response(client, command[1] == TRUES)
          else
            raise 'The given command is not supported, refer to the protocol for the correct syntax'
          end
        end
      end
    rescue Exception => e
      puts "[exception] Client ##{client[:id]} from #{client[:ip]}: #{e.message}".red
      puts e.backtrace.join("\n").yellow

      client[:socket].puts "#{ERROR} #{e.message}"
    ensure
      puts "[info] Client ##{client[:id]} from #{client[:ip]} disconnects"

      client[:socket].close
      @clients.delete(client)
    end
  end
end