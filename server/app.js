const express = require('express');
const app = express();

// Start a server (Port 8080 by Default)
const port = process.env.PORT || 8080;
const server = app.listen(process.env.PORT || 8080, () => {
  console.log(`Server running on port: ${port}`);
});

// Init socket io
const io = require('socket.io')(server);

// When a new client connects to our server
io.sockets.on('connection', socket => {
  console.log(`Client (id: ${socket.id}) connected.`);
  const randNumInt = setInterval(() => {
    socket.emit('reading', {
      data: parseFloat((Math.random() * 5).toFixed(3))
    });
  }, 500);

  // When a client sends awk
  socket.on('awk', data => {
    console.log(`Client (id: ${socket.id}) awknowledged -> ${data}`);
  });

  // When a client disconnects
  socket.on('disconnect', () => {
    clearInterval(randNumInt);
    console.log(`Client (id: ${socket.id}) disconnected.`);
  });
});
