import EventEmitter from 'events';
import type Client = require('chromecast-api');
import type Device = require('chromecast-api/lib/device');

export function getChromecasts(client: Client) {
	const chromecasts = client.devices.map((device) => device.friendlyName);
	return { status: 'ok', response: chromecasts };
}

export function getChromecast(client: Client, chromecastName: string) {
	const device = client.devices.find((device) => device.friendlyName === chromecastName);
	return device;
}

export function errorMessage(err: Error) {
	return { 'status': 'error', 'response': `${err.name}: ${err.message}` };
}

export function newChromecast(client: Client, socket: EventEmitter) {
	const callback = (device: Device) => {
		socket.emit('newChromecast', device.friendlyName);
	}

	client.on('device', callback);

	socket.on('disconnect', () => {
		client.removeListener('device', callback);
	});
}
