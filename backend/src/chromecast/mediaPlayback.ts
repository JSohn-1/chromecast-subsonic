import { stream } from '../subsonic/stream';

import type Client = require('chromecast-api');
import Device = require('chromecast-api/lib/device');

import eventEmitter from 'events';

import { getChromecast, errorMessage } from './utilChromecast';
import { Subsonic } from '../subsonic/subsonic';
import { Chromecast } from './chromecast';

const listeners = {} as { [uuid: string]: (status: Device.DeviceStatus) => void };
const selectedChromecasts = {} as { [uuid: string]: {device: Device, socket: eventEmitter} };

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

export function pause(client: Client, uuid: string) {
	if (!selectedChromecasts[uuid]) {
		return new Promise((resolve) => {
			resolve({ status: 'error', response: 'device not selected' });
		
		});
	}
	const device = selectedChromecasts[uuid].device;

	if (!device) {
		return new Promise((resolve) => {
			resolve({ status: 'error', response: 'device not selected' });
		});
	}

	return new Promise<string>((resolve) => {
		device.pause((err) => {
			if (err) {
				console.error(err);
				resolve(JSON.stringify(errorMessage(err)));
			}
			resolve(JSON.stringify({ status: 'ok', response: 'paused' }));
		});
	});
}

export function resume(client: Client, uuid: string) {
	if (!selectedChromecasts[uuid]) {
		return new Promise((resolve) => {
			resolve({ status: 'error', response: 'device not selected' });
		
		});
	}

	const device = selectedChromecasts[uuid].device;

	if (!device) {
		return new Promise((resolve) => {
			resolve({ status: 'error', response: 'device not selected' });
		});
	}

	return new Promise((resolve) => {
		device.resume((err?: Error) => {
			if (err) {

				if (err.message === 'no session started' && Subsonic.getCurrentSong(device).index !== -1) {
					const song = Subsonic.getCurrentSong(device);

					Chromecast.play(device.friendlyName, song.id).then(() => {
						resolve({ status: 'ok', response: 'resumed' });
					});
				}
				console.error(err);

				resolve(errorMessage(err));
			}
			resolve({ status: 'ok', response: 'resumed' });
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
		socket.emit('subscribe', JSON.stringify({ status: 'ok', response: {chromecastStatus: status, queue: Subsonic.getCurrentSong(device)} }));
	};

	device.getStatus((err, status) => {
		if (err) {
			socket.emit('subscribe', JSON.stringify({ status: 'error', response: err }));
			return;
		}
		socket.emit('subscribe', JSON.stringify({ status: 'ok', response: {chromecastStatus: status, queue: Subsonic.getCurrentSong(device)} }));
	});

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

export function playQueue(client: Client, uuid: string, id: string, socket: eventEmitter) {
	if (!selectedChromecasts[uuid]) {
		socket.emit('playQueueShuffle', { status: 'error', response: 'device not selected' });
		return;
	}

	const device = selectedChromecasts[uuid].device;

	if (!device) {
		socket.emit('playQueue', { status: 'error', response: 'device not selected' });
		return;
	}

	Subsonic.queuePlaylist(id, device).then((_) => {
		const song = Subsonic.startNextSong(device);
		Chromecast.play(device.friendlyName, song.id).then(() => {
			socket.emit('playQueue', song);
		});
	});

	device.on('finished', () => {
		const song = Subsonic.startNextSong(device);
		socket.emit('playQueue', song);

		for(const key in selectedChromecasts) {
			selectedChromecasts[key].socket.emit('playQueue', song);
		}

		Chromecast.play(device.friendlyName, song.id).then(() => {
			socket.emit('playQueue', song);
		});
	});
}

export function playQueueShuffle(client: Client, uuid: string, id: string, socket: eventEmitter) {
	if (!selectedChromecasts[uuid]) {
		socket.emit('playQueueShuffle', { status: 'error', response: 'device not selected' });
		return;
	}

	const device = selectedChromecasts[uuid].device;

	if (!device) {
		socket.emit('playQueue', { status: 'error', response: 'device not selected' });
		return;
	}

	Subsonic.queuePlaylistShuffle(id, device).then((_) => {
		// socket.emit('playQueueShuffle', _);

		const song = Subsonic.startNextSong(device);
		Chromecast.play(device.friendlyName, song.id).then(() => {
			for (const key in selectedChromecasts) {
				if(selectedChromecasts[key].device === device) {
					selectedChromecasts[key].socket.emit('playQueue', song);
				}
			}
		});
	});

	device.on('finished', () => {
		const song = Subsonic.startNextSong(device);

		Chromecast.play(device.friendlyName, song.id).then(() => {
			for (const key in selectedChromecasts) {
				if(selectedChromecasts[key].device === device) {
					selectedChromecasts[key].socket.emit('playQueue', song);
				}
			}
		});
	});
}

export function skip(client: Client, uuid: string, socket: eventEmitter) {
	const device = selectedChromecasts[uuid].device;

	if (!device) {
		return new Promise((resolve) => {
			resolve({ status: 'error', response: 'device not selected' });
		});
	}

	const song = Subsonic.startNextSong(device);
	Chromecast.play(device.friendlyName, song.id);

	// Notify all UUIDs that selected this Chromecast that the song was skipped
	for (const key in selectedChromecasts) {
		if(selectedChromecasts[key].device === device) {
			selectedChromecasts[key].socket.emit('playQueue', song);
		}
	}

	// socket.emit('playQueue', song);

	return new Promise<string>((resolve) => {
		resolve(JSON.stringify({ status: 'ok', response: song }));
	});
}

export function getCurrentSong(client: Client, uuid: string, socket: eventEmitter) {
	const device = selectedChromecasts[uuid].device;

	if (!device) {
		socket.emit('getCurrentSong', { status: 'error', response: 'device not found' });
		return;
	}

	socket.emit('getCurrentSong', { status: 'ok', response: Subsonic.getCurrentSong(device) });
}

export function selectChromecast(client: Client, chromecastName: string, uuid: string, socket: eventEmitter) {
	const device = getChromecast(client, chromecastName);

	if (!device) {
		socket.emit('selectChromecast', { status: 'error', response: 'device not found' });
		return;
	}

	if (uuid in listeners) {
		device.removeListener('status', listeners[uuid]);
		delete listeners[uuid];
	}

	const listener = (status: Device.DeviceStatus) => {
		socket.emit('subscribe', { status: 'ok', response: {chromecastStatus: status, queue: Subsonic.getCurrentSong(device)} });
	};

	device.on('status', listener);
	listeners[uuid] = listener;

	selectedChromecasts[uuid] = { device, socket };
	socket.emit('selectChromecast', { status: 'ok', response: chromecastName });
}

export function getStatus(client: Client, uuid: string, socket: eventEmitter) {
	const device = selectedChromecasts[uuid].device;

	if (!device) {
		socket.emit('getStatus', { status: 'error', response: 'chromecast not selected' });
		return;
	}

	try{
		device.getStatus((err, status) => {
			if (err) {
				socket.emit('getStatus', { status: 'error', response: `${err.name}: ${err.message}` });
				return;
			}
			socket.emit('getStatus', { status: 'ok', response: status });
		});
	} catch (err) {
		socket.emit('getStatus', { status: 'error', response: 'unknown' });
	}
}

export function clearListener(uuid: string) {
	if (uuid in listeners) {
		selectedChromecasts[uuid].device.removeListener('status', listeners[uuid]);
		delete listeners[uuid];
	}
	if (uuid in selectedChromecasts) {
		delete selectedChromecasts[uuid];
	}
}
