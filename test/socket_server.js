const http = require('net')
const port = 3111

const requestHandler = (socket) => {
  console.log("CONNECTED: " + socket.remoteAddress)
  socket.on('data', function(data) {
    console.log(data);
  });
  socket.on('end', () => {
    console.log('client disconnected');
  });
  socket.write("SOK")
}

const server = http.createServer(requestHandler)

server.listen(port, (err) => {
  if (err) {
    return console.log('something bad happened', err)
  }

  console.log(`server is listening on ${port}`)
})