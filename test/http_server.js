// test http server - node.js

const http = require('http')
const port = 3111

const requestHandler = (request, response) => {
  console.log(request.url)
  response.end('Hello from index.html!')
}

const server = http.createServer(requestHandler)

server.listen(port, (err) => {
  if (err) {
    return console.log('something bad happened', err)
  }

  console.log(`server is listening on ${port}`)
})