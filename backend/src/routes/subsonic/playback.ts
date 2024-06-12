import { Socket } from 'socket.io';

import { Subsonic } from '../../subsonic/subsonic';
import { Playback } from '../../subsonic/playback';

const queuePlaylist = (socket: Socket, uuid: string) => {
	socket.on('queuePlaylist', (id: string, shuffle?: boolean) => {
		const username = Subsonic.apis[uuid].username;

		// console.log(Playback.users[username]);

		Playback.users[username].playback.playPlaylist(socket, id, shuffle);
	});
};

const handleDisconnect = (socket: Socket) => {
	socket.on('disconnect', () => {
		Playback.disconnect(socket);
	});
};

export const playback = (socket: Socket, uuid: string) => {
	queuePlaylist(socket, uuid);
	handleDisconnect(socket);
};
