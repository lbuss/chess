require 'socket'                # Get sockets from stdlib

server = TCPServer.open(2000)   # Socket to listen on port 2000
loop {                          # Servers run forever
  Thread.start(server.accept) do |client|
    client.puts(Time.now.ctime) # Send the time to the client
    string = nil
    until string != nil
      client.puts "waiting for string"
      string = server.accept.write
    end
    client.puts(string)
	  client.puts "Closing the connection. Bye!"
    client.close               # Disconnect from the client
  end
}

        if piece.creates_check(move)
         temp_value += @piece_value['Check']
        end
        
        if piece.valid_enemy(move)
          enemy = @board[move]
          p @piece_value[enemy.class.name]
          temp_value += @piece_value[enemy.class.name]
        end
        
        if temp_value > value
          value = temp_value
          moves[piece] = move
        end