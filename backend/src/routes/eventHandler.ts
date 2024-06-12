// import { v4 as uuidv4 } from 'uuid';
import { Socket } from 'socket.io';
// import { getMediaInfo } from '../media/mediaInfo';
// import { Chromecast } from '../chromecast/chromecast';

import { subsonicWrapper } from './subsonic/wrapper';
// import { playback } from './subsonic/playback';
// import { chromecastRoutes } from './chromecast';

export class Sockets {
	static sockets: { [uuid: string]: Socket } = {};
}

export const eventHandler = (socket: Socket) => {
	// const uuid = uuidv4();
	Sockets.sockets[socket.id] = socket;
	console.log('a user connected: ' + socket.id);

	// socket.on('getMediaInfo', (id: string) => {
	// 	getMediaInfo(uuid, id).then((_) => {
	// 		socket.emit('getMediaInfo', _);
	// 	});
	// });

	// socket.onAny((event, ...args) => {
	// 	console.log(event, args);
	// });

	socket.emit('uuid', { id: socket.id });

	socket.on('disconnect', () => {
		// Chromecast.clearListener(uuid);
		console.log('a user disconnected');
	});

	subsonicWrapper(socket, socket.id);
	// chromecastRoutes(socket, uuid);
};
