import { Socket } from 'socket.io';

import { Subsonic } from '../../subsonic/subsonic';

const getSong = (socket: Socket) => {
	socket.on('getSong', (id: string) => {
		if (!id) {
			socket.emit(JSON.stringify({ status: 'error', response: 'no id provided' }));
			return;
		}
		Subsonic.getSong(id).then((_) => {
			socket.emit('getSong', _);
		});
	});
};

const getSongInfo = (socket: Socket) => {
	socket.on('getSongInfo', (id: string) => {
		if (!id) {
			socket.emit('getSongInfo', { status: 'error', response: 'no id provided' });
			return;
		}
		Subsonic.getSongInfo(id).then((_) => {
			socket.emit('getSongInfo', _);
		});
	});
};

export const media = (socket: Socket) => {
	getSong(socket);
	getSongInfo(socket);
};
