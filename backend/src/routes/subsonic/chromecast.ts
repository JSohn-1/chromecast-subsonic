import { Socket } from 'socket.io';
import { Chromecast } from '../../subsonic/chromecast';

const getChromecasts = (socket: Socket) => {
	socket.on('getChromecasts', () => {
		socket.emit('getChromecasts', Chromecast.getChromecasts());
	});
};

const newChromecast = (socket: Socket) => {
	Chromecast.newChromecast(socket);
};

const selectChromecast = (socket: Socket) => {
	socket.on('selectChromecast', (chromecastName: string) => {
		const device = Chromecast.getChromecast(chromecastName);

		if (!device) {
			socket.emit('selectChromecast', { status: 'error', response: 'device not found' });
			return;
		}

		socket.emit('selectChromecast', { status: 'ok', response: device });
	});
};

export const chromecast = (socket: Socket) => {
	getChromecasts(socket);
	newChromecast(socket);
	selectChromecast(socket);
};
