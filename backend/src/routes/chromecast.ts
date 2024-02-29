import { Socket } from 'socket.io';

import { Chromecast } from '../chromecast/chromecast';

const queuePlaylist = (socket: Socket, uuid: string) => {
	socket.on('queuePlaylist', (id: string) => {
		Chromecast.playQueue(uuid, id, socket);
	});
};

const queuePlaylistShuffle = (socket: Socket, uuid: string) => {
	socket.on('queuePlaylistShuffle', (id: string) => {
		Chromecast.playQueueShuffle(uuid, id, socket);
	});
};

const resume = (socket: Socket, uuid: string) => {
	socket.on('resume', () => {
		Chromecast.resume(uuid);
	});
};

const pause = (socket: Socket, uuid: string) => {
	socket.on('pause', () => {
		Chromecast.pause(uuid);
	});
};

const skip = (socket: Socket, uuid: string) => {
	socket.on('skip', () => {
		Chromecast.skip(uuid);
	});
};

const previous = (socket: Socket, uuid: string) => {
	socket.on('previous', () => {
		Chromecast.previous(uuid, socket);
	});
};

const seek = (socket: Socket, uuid: string) => {
	socket.on('seek', (time: number) => {
		Chromecast.seek(uuid, time, socket);
	});
};

const getCurrentSong = (socket: Socket, uuid: string) => {
	socket.on('getCurrentSong', () => {
		Chromecast.getCurrentSong(uuid, socket);
	});
};

const getStatus = (socket: Socket, uuid: string) => {
	socket.on('getStatus', () => {
		Chromecast.getStatus(uuid, socket);
	});
};

const selectChromecast = (socket: Socket, uuid: string) => {
	socket.on('selectChromecast', (chromecastName: string) => {
		Chromecast.selectChromecast(chromecastName, uuid, socket);
	});
};

const newChromecast = (socket: Socket) => {
	Chromecast.newChromecast(socket);
};

const getChromecasts = (socket: Socket) => {
	socket.on('getChromecasts', () => {
		socket.emit('getChromecasts', Chromecast.getChromecasts());
	});
};

const close = (socket: Socket, uuid: string) => {
	socket.on('close', () => {
		Chromecast.close(uuid, socket);
	});
};

export const chromecastRoutes = (socket: Socket, uuid: string) => {
	queuePlaylist(socket, uuid);
	queuePlaylistShuffle(socket, uuid);

	resume(socket, uuid);
	pause(socket, uuid);
	skip(socket, uuid);
	previous(socket, uuid);
	seek(socket, uuid);
	close(socket, uuid);

	getCurrentSong(socket, uuid);
	getStatus(socket, uuid);
	selectChromecast(socket, uuid);
	newChromecast(socket);
	getChromecasts(socket);
};
