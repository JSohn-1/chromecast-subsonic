import { Socket } from 'socket.io';

// import { utils } from './utils';
// import { playlists } from './playlists';
import { media } from './media';

import { Subsonic } from '../../subsonic/subsonic';
import { Notify } from '../../subsonic/notify';
import { Playback } from '../../subsonic/playback';
import { playback } from './playback';
import { chromecast } from './chromecast';

export const subsonicWrapper = (socket: Socket, uuid: string) => {
	socket.on('login', async (username: string, password: string ) => {
		const login = await Subsonic.login(uuid, username, password);
		socket.emit('login', login);

		if (login.success) {
			Notify.newUser(username, uuid, socket);

			Playback.savePlayback(Subsonic.apis[uuid]);

			socket.on('disconnect', () => {
				Subsonic.logout(uuid);
				Notify.removeUser(uuid);
			});
		}
	});

	socket.on('isSignedIn', () => {
		socket.emit('isSignedIn', Subsonic.signedIn(uuid));
	});

	// utils(socket);
	// playlists(socket);
	media(socket, uuid);
	playback(socket, uuid);
	chromecast(socket);

};
