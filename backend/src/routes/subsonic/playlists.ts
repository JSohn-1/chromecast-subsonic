import { Socket } from "socket.io";

import { Subsonic } from "../../subsonic/subsonic";

const getPlaylists = (socket: Socket) => {
	socket.on('getPlaylists', () => {
		Subsonic.getPlaylists().then((_) => {
			socket.emit('getPlaylists', _);
		});
	});
}

const getPlaylist = (socket: Socket) => {
	socket.on('getPlaylist', (id: string) => {
		if (!id) {
			socket.emit(JSON.stringify({ status: 'error', response: 'no id provided' }));
			return;
		}
		Subsonic.getPlaylist(id).then((_) => {
			socket.emit('getPlaylist', _);
		});
	});
}

export const playlists = (socket: Socket) => {
	getPlaylists(socket);
	getPlaylist(socket);
}