import { Socket } from 'socket.io';

import { Subsonic } from '../../subsonic/subsonic';

import { getMediaInfo } from '../../media/mediaInfo';

const getSong = (socket: Socket, uuid: string) => {
	socket.on('getSong', (id: string) => {
		Subsonic.apis[uuid].getSong({id}).then((_) => {
			socket.emit('getSong', _);
		});
	});
};

const getSongInfo = (socket: Socket, uuid: string) => {
	socket.on('getSongInfo', (id: string) => {
		getMediaInfo(uuid, id).then((_) => {
			socket.emit('getSongInfo', _);
		});
	});
};

// const getSongInfo = (socket: Socket, uuid: string) => {
// 	socket.on('getSongInfo', (id: string) => {
// 		if (!id) {
// 			socket.emit('getSongInfo', { status: 'error', response: 'no id provided' });
// 			return;
// 		}
// 		Subsonic.getSongInfo(id).then((_) => {
// 			socket.emit('getSongInfo', _);
// 		});
// 	});
// };

export const media = (socket: Socket, uuid: string) => {
	getSong(socket, uuid);
	getSongInfo(socket, uuid);
	// getSongInfo(socket);
};
