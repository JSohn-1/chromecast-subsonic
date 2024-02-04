import { stream } from '../subsonic/stream';

import type Client = require('chromecast-api');
import Device = require('chromecast-api/lib/device');

import eventEmitter from 'events';

import { getChromecast, errorMessage } from './utilChromecast';
import { Subsonic } from '../subsonic/subsonic';
import { Chromecast } from './chromecast';

const listeners = {} as { [uuid: string]: (status: Device.DeviceStatus) => void };

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

export function subscribe(client: Client, chromecastName: string, uuid: string, socket: eventEmitter) {
	const device = getChromecast(client, chromecastName);

	if (!device) {
		socket.emit('subscribe', JSON.stringify({ status: 'error', response: 'device not found' }));
		return;
	}

	const listener = (status: Device.DeviceStatus) => {
		socket.emit('subscribe', JSON.stringify({ status: 'ok', response: {chromecastStatus: status, queue: Subsonic.getCurrentSong()} }));
	};

	device.on('status', listener);
	listeners[uuid] = listener;
}

export function unsubscribe(client: Client, chromecastName: string, uuid: string, socket: eventEmitter) {
	const device = getChromecast(client, chromecastName);

	if (!device) {
		socket.emit('unsubscribe', JSON.stringify({ status: 'error', response: 'device not found' }));
		return;
	}

	device.removeListener('status', listeners[uuid]);
	delete listeners[uuid];
}

export function playQueue(client: Client, chromecastName: string, socket: eventEmitter) {
	const device = getChromecast(client, chromecastName);

	if (!device) {
		socket.emit('playQueue', JSON.stringify({ status: 'error', response: 'device not found' }));
		return;
	}

	device.on('finished', () => {
		const song = Subsonic.startNextSong();
		Chromecast.play(chromecastName, song.id).then(() => {
			socket.emit('playQueue', song);
		});
	});

	socket.on('skip', (chromecastName: string) => {
		if (chromecastName !== device.friendlyName) return;

		const song = Subsonic.startNextSong();
		Chromecast.play(chromecastName, song.id).then(() => {
			socket.emit('playQueue', song);
		});
	});

	const song = Subsonic.startNextSong();
	Chromecast.play(chromecastName, song.id).then(() => {
		socket.emit('playQueue', song);
	});
}
