import { Socket } from "socket.io";

import { Chromecast } from "../chromecast/chromecast"

const queuePlaylist = (socket: Socket, uuid: string) => {
	socket.on('playQueue', (id: string) => {
		Chromecast.playQueue(uuid, id, socket);
	});
};

const queuePlaylistShuffle = (socket: Socket, uuid: string) => {
	socket.on('playQueueShuffle', (id: string) => {
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
		Chromecast.skip(uuid, socket);
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

export const chromecastRoutes = (socket: Socket, uuid: string) => {
	queuePlaylist(socket, uuid);
	queuePlaylistShuffle(socket, uuid);

	resume(socket, uuid);
	pause(socket, uuid);
	skip(socket, uuid);

	getCurrentSong(socket, uuid);
	getStatus(socket, uuid);
	selectChromecast(socket, uuid);
	newChromecast(socket);
};