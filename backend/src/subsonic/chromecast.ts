import EventEmitter from 'events';
import ChromecastAPI from 'chromecast-api';
import type Device = require('chromecast-api/lib/device');

export class Chromecast {
	static client: ChromecastAPI = new ChromecastAPI();

	static newChromecast(socket: EventEmitter) {
		const callback = (device: Device) => {
			socket.emit('newChromecast', device.friendlyName);
		};
	
		Chromecast.client.on('device', callback);
	
		socket.on('disconnect', () => {
			Chromecast.client.removeListener('device', callback);
		});
	}

	static getChromecasts() {
		const chromecasts = Chromecast.client.devices.map((device) => device.friendlyName);
		return { status: 'ok', response: chromecasts };
	}

	static getChromecast(chromecastName: string) {
		const device = Chromecast.client.devices.find((device) => device.friendlyName === chromecastName);
		return device;
	}
}
