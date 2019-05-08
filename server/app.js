const express = require('express');
const app = express();

const sockets = [];

app.use(express.json());

app.post('/', (req, res) => {
  const { value } = req.body;
  console.log('Read from Detector: ', value);
  for (let socket of sockets) {
    socket.emit('reading', { data: value || 0 });
  }
  res.sendStatus(200);
});

app.use('*', (req, res) => {
  res.status(404).json({ err: 'not found' });
});

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
  sockets.push(socket);

  // When a client disconnects
  socket.on('disconnect', () => {
    const index = sockets.indexOf(socket.id);
    if (index !== -1) sockets.splice(index, 1);
    console.log(`Client (id: ${socket.id}) disconnected.`);
  });
});
