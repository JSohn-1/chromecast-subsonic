import { Socket } from 'socket.io';

import { Subsonic } from '../../subsonic/subsonic';
import { Playback } from '../../subsonic/playback';

const queuePlaylist = (socket: Socket, uuid: string) => {
	socket.on('queuePlaylist', (id: string, name: string, shuffle?: boolean) => {
		const username = Subsonic.apis[uuid].username;

		Playback.users[username].playback.playPlaylist(id, shuffle);
	});
};

const setIndex = (socket: Socket, uuid: string) => {
	socket.on('setIndex', (index: number) => {
		const username = Subsonic.apis[uuid].username;

		Playback.users[username].playback.setIndex(index);
	});
};

const handleDisconnect = (socket: Socket) => {
	socket.on('disconnect', () => {
		Playback.disconnect(socket);
	});
};

const resume = (socket: Socket, uuid: string) => {
	socket.on('resume', () => {
		const username = Subsonic.apis[uuid].username;

		Playback.users[username].playback.resume(uuid);
	});
};

const pause = (socket: Socket, uuid: string) => {
	socket.on('pause', () => {
		const username = Subsonic.apis[uuid].username;

		Playback.users[username].playback.pause(uuid);
	});
};

export const playback = (socket: Socket, uuid: string) => {
	queuePlaylist(socket, uuid);
	setIndex(socket, uuid);
	handleDisconnect(socket);
	resume(socket, uuid);
	pause(socket, uuid);
};
