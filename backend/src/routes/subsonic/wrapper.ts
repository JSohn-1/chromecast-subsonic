import { Socket } from 'socket.io';

// import { utils } from './utils';
// import { playlists } from './playlists';
import { media } from './media';

import { Subsonic } from '../../subsonic/subsonic';

export const subsonicWrapper = (socket: Socket, uuid: string) => {

	socket.on('login', (username: string, password: string ) => {
		Subsonic.login(uuid, username, password).then((_) => {
			socket.emit('login', _);
		});
	});

	socket.on('isSignedIn', () => {
		socket.emit('isSignedIn', Subsonic.signedIn(uuid));
	});

	// utils(socket);
	// playlists(socket);
	media(socket, uuid);
};
