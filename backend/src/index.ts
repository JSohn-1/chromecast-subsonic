import { Subsonic } from './subsonic/subsonic';
import { getPlaylistInfo } from './download/helper';
import { Chromecast } from './chromecast/chromecast';

import express from 'express';
import { Server } from 'socket.io';
import { createServer } from 'http';
import { v4 as uuidv4 } from 'uuid';

const app = express();
const port = 3000;

const httpServer = createServer(app);
const io = new Server(httpServer);

io.on('connection', (socket) => {
	const uuid = uuidv4();

	console.log('a user connected: ' + uuid);
	socket.on('disconnect', () => {
		console.log('a user disconnected');
	});

	socket.on('ping', () => {
		Subsonic.ping().then((_: string) => {
			socket.emit('ping', _);
		});
	});

	socket.on('getPlaylists', () => {
		Subsonic.getPlaylists().then((_: string) => {
			socket.emit('getPlaylists', _);
		});
	});

	socket.on('getPlaylist', (id: string) => {
		if (!id) {
			socket.emit(JSON.stringify({ status: 'error', response: 'no id provided' }));
			return;
		}
		Subsonic.getPlaylist(id).then((_: string) => {
			socket.emit('getPlaylist', _);
		});
	});

	socket.on('playlistInfo', (id: string) => {
		if (!id) {
			socket.emit(JSON.stringify({ status: 'error', response: 'no id provided' }));
			return;
		}
		getPlaylistInfo(id).then((_: string) => {
			socket.emit('playlistInfo', _);
		});
	});

	socket.on('getSongInfo', (id: string) => {
		if (!id) {
			socket.emit(JSON.stringify({ status: 'error', response: 'no id provided' }));
			return;
		}
		Subsonic.getSongInfo(id).then((_: string) => {
			socket.emit('getSongInfo', _);
		});
	});

	socket.on('getChromecasts', () => {
		socket.emit('getChromecasts', Chromecast.getChromecasts());
	});

	socket.on('getSong', (id: string) => {
		if (!id) {
			socket.emit(JSON.stringify({ status: 'error', response: 'no id provided' }));
			return;
		}
		Subsonic.getSong(id).then((_: string) => {
			socket.emit('getSong', _);
		});
	});

	socket.on('play', (songId: string, chromecastName: string) => {
		if (!songId || !chromecastName) {
			socket.emit(JSON.stringify({ status: 'error', response: 'incorrect parameters' }));
			return;
		}
		Chromecast.play(chromecastName, songId).then((_: string) => {
			socket.emit('play', _);
		});
	});

	socket.on('pause', (chromecastName: string) => {
		if (!chromecastName) {
			socket.emit(JSON.stringify({ status: 'error', response: 'no chromecast provided' }));
			return;
		}
		Chromecast.pause(chromecastName).then((_: string) => {
			socket.emit('pause', _);
		});
	});

	socket.on('resume', (chromecastName: string) => {
		if (!chromecastName) {
			socket.emit(JSON.stringify({ status: 'error', response: 'no chromecast provided' }));
			return;
		}
		Chromecast.resume(chromecastName).then((_: string) => {
			socket.emit('resume', _);
		});
	});

	socket.on('subscribe', (chromecastName: string) => {
		if (!chromecastName) {
			socket.emit(JSON.stringify({ status: 'error', response: 'no chromecast provided' }));
			return;
		}
		Chromecast.subscribe(chromecastName, uuid, socket);
	});

	socket.on('unsubscribe', (chromecastName: string) => {
		if (!chromecastName) {
			socket.emit(JSON.stringify({ status: 'error', response: 'no chromecast provided' }));
			return;
		}
		Chromecast.unsubscribe(chromecastName, uuid, socket);
	});

	Chromecast.newChromecast(socket);

	socket.on('queuePlaylist', (id: string, chromecastName: string) => {
		Subsonic.queuePlaylist(id).then((_: string) => {
			Chromecast.playQueue(chromecastName, socket);
			socket.emit('queuePlaylist', _);
		});
	});
});

httpServer.listen(port, () => {
	console.log(`Server listening at http://localhost:${port}`);
});
