import { stream } from '../subsonic/stream';

import type Client = require('chromecast-api');

import { getChromecast, errorMessage } from './utilChromecast';
import eventEmitter from 'events';

export function play(client: Client, chromecastName: string, songId: string) {
	const device = getChromecast(client, chromecastName);

	return new Promise<string>((resolve, reject) => {
		if (!device) {
			resolve(JSON.stringify({ status: 'error', response: 'device not found' }));
			return;
		}

		stream(songId)
			.then((response: { songURL: string, coverURL: string, title: string }) => {
				const media = {
					url: response.songURL,
					cover: {
						title: response.title,
						url: response.coverURL
					}
				};
				return media;
			})
			.then((media: { url: string; cover: { title: string; url: string; }; }) => {
				device.play(media, (err?: Error) => {
					if (err) {
						console.error(err);
						resolve(JSON.stringify(errorMessage(err)));
					}
					resolve(JSON.stringify({ status: 'ok', response: 'playing' }));
				});
			})
			.catch((err) => {
				console.error(err);
				reject({ status: 'error', response: err });
			});
	});
}

export function pause(client: Client, chromecastName: string) {
	const device = getChromecast(client, chromecastName);

	return new Promise<string>((resolve) => {
		if (!device) {
			resolve(JSON.stringify({ status: 'error', response: 'device not found' }));
			return;
		}

		device.pause((err) => {
			if (err) {
				console.error(err);
				resolve(JSON.stringify(errorMessage(err)));
			}
			resolve(JSON.stringify({ status: 'ok', response: 'paused' }));
		});
	});
}

export function resume(client: Client, chromecastName: string) {
	const device = getChromecast(client, chromecastName);

	return new Promise<string>((resolve) => {
		if (!device) {
			resolve(JSON.stringify({ status: 'error', response: 'device not found' }));
			return;
		}

		device.resume((err?: Error) => {
			if (err) {
				console.error(err);
				resolve(JSON.stringify(errorMessage(err)));
			}
			resolve(JSON.stringify({ status: 'ok', response: 'resumed' }));
		});
	});
}

export function subscribe(client: Client, chromecastName: string, socket: eventEmitter) {
	const device = getChromecast(client, chromecastName);

	if (!device) {
		socket.emit('subscribe', JSON.stringify({ status: 'error', response: 'device not found' }));
		return;
	}

	device.on('status', (status) => {
		socket.emit('subscribe', JSON.stringify({ status: 'ok', response: status }));
	});
}

export function unsubscribe(client: Client, chromecastName: string, socket: eventEmitter) {
	const device = getChromecast(client, chromecastName);

	if (!device) {
		socket.emit('unsubscribe', JSON.stringify({ status: 'error', response: 'device not found' }));
		return;
	}

	device.removeAllListeners('status');
}
