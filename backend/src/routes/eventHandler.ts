import { v4 as uuidv4 } from 'uuid';
import { Socket } from 'socket.io';
// import { getMediaInfo } from '../media/mediaInfo';
// import { Chromecast } from '../chromecast/chromecast';

import { subsonicWrapper } from './subsonic/wrapper';
// import { chromecastRoutes } from './chromecast';

export const eventHandler = (socket: Socket) => {
	const uuid = uuidv4();
	
	console.log('a user connected: ' + uuid);

	// socket.on('getMediaInfo', (id: string) => {
	// 	getMediaInfo(uuid, id).then((_) => {
	// 		socket.emit('getMediaInfo', _);
	// 	});
	// });

	socket.on('disconnect', () => {
		// Chromecast.clearListener(uuid);
		console.log('a user disconnected');
	});

	subsonicWrapper(socket, uuid);
	// chromecastRoutes(socket, uuid);
};
