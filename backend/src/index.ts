import { eventHandler } from './routes/eventHandler';

import express from 'express';
import { Server } from 'socket.io';
import { createServer } from 'http';

const app = express();
const port = 2001;

const httpServer = createServer(app);
const io = new Server(httpServer);

io.on('connection', (socket) => {
	eventHandler(socket);
});

httpServer.listen(port, () => {
	console.log(`Server listening at http://localhost:${port}`);
});
