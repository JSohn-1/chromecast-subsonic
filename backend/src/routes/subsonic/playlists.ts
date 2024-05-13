import { Socket } from 'socket.io';

import { Subsonic } from '../../subsonic/subsonic';

const getPlaylists = (uuid: string, socket: Socket) => {
	socket.on('getPlaylists', () => {
		Subsonic.apis[uuid].getPlaylists().then((_) => {
			socket.emit('getPlaylists', _);
		});
	});
};

const getPlaylist = (uuid: string, socket: Socket) => {
	socket.on('getPlaylist', (id: string) => {
		if (!id) {
			socket.emit(JSON.stringify({ status: 'error', response: 'no id provided' }));
			return;
		}
		Subsonic.apis[uuid].getPlaylist({id}).then((_) => {
			socket.emit('getPlaylist', _);
		});
	});
};

export const playlists = (uuid: string, socket: Socket) => {
	getPlaylists(uuid, socket);
	getPlaylist(uuid, socket);
};
// 
