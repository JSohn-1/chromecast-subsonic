import { Socket } from 'socket.io';

// import { utils } from './utils';
// import { playlists } from './playlists';
import { media } from './media';

import { Subsonic } from '../../subsonic/subsonic';
import { Notify } from '../../subsonic/notify';

export const subsonicWrapper = (socket: Socket, uuid: string) => {
	socket.on('login', async (username: string, password: string ) => {
		const login = await Subsonic.login(uuid, username, password);
		socket.emit('login', login);

		if (login.success) {
			Notify.newUser(username, uuid, socket);
		}
	});

	socket.on('isSignedIn', () => {
		socket.emit('isSignedIn', Subsonic.signedIn(uuid));
	});

	// utils(socket);
	// playlists(socket);
	media(socket, uuid);
};
