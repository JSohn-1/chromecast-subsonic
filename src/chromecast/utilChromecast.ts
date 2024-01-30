import EventEmitter from 'events';
import type Client = require('chromecast-api');

export function getChromecasts(client: Client) {
	const chromecasts = client.devices.map((device) => device.friendlyName);
	return { 'status': 'ok', 'response': chromecasts };
}

export function getChromecast(client: Client, chromecastName: string) {
	const device = client.devices.find((device) => device.friendlyName === chromecastName);
	return device;
}

export function errorMessage(err: Error) {
	return { 'status': 'error', 'response': `${err.name}: ${err.message}` };
}

export function newChromecast(client: Client, socket: EventEmitter) {
	client.on('device', (device) => {
		socket.emit('newChromecast', device.friendlyName);
	});
}
