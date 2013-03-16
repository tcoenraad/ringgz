require_relative 'server'
require 'socket'

GREET = 'greet'
JOIN  = 'join'
ERROR = 'error'

server = TCPServer.open(7269)
@server = Server.new
@clients = []

loop do
  Thread.start(server.accept) do |client|
    begin
      client = {
        :socket => client,
        :id => @clients.count,
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

            client[:name] = command[1]
            client[:socket].puts "#{GREET} 0 0"
          else
            raise 'You first need to introduce yourself to continue -- `greet NAME`'
          end
        else
          if command.first == JOIN
            @server.join(client, command[1].to_i)
          else
            raise 'The given command is not supported, refer to the protocol for the correct syntax'
          end
        end
      end
    rescue Exception => e
      puts "[exception] Client ##{client[:id]} from #{client[:ip]}: #{e.message}"
      puts e.backtrace.join("\n")

      client[:socket].puts "#{ERROR} #{e.message}"
    ensure
      client[:socket].close
      @clients.delete(client)
    end
  end
end