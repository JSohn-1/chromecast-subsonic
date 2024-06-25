import { eventHandler } from './routes/eventHandler';

import express from 'express';
import { Server } from 'socket.io';
import { createServer } from 'http';

import { subsonicRoutes, queueRoutes, playbackRoutes } from './routes/proxy';

const app = express();
const port = 3000;

const httpServer = createServer(app);
const io = new Server(httpServer);

io.on('connection', (socket) => {
	eventHandler(socket);
});

subsonicRoutes(app);
queueRoutes(app);
playbackRoutes(app);

httpServer.listen(port, () => {
	console.log(`Server listening at http://localhost:${port}`);
});
