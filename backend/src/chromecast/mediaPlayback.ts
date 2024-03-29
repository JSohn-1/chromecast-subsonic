import { stream } from '../subsonic/stream';

import type Client = require('chromecast-api');
import Device = require('chromecast-api/lib/device');

import eventEmitter from 'events';

import { getChromecast, errorMessage } from './utilChromecast';
import { Subsonic } from '../subsonic/subsonic';
import { Chromecast } from './chromecast';

const listeners: { [uuid: string]: (status: Device.DeviceStatus) => void } = {};
const selectedChromecasts: { [uuid: string]: {device: Device, socket: eventEmitter} } = {};

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
		try{
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
		} catch (err) {
			console.error(err);
			resolve(errorMessage(err as Error));
		}
	});
}

export function playQueue(client: Client, uuid: string, id: string, socket: eventEmitter) {
	if (!selectedChromecasts[uuid]) {
		socket.emit('playQueue', { status: 'error', response: 'device not selected' });
		return;
	}

	const device = selectedChromecasts[uuid].device;

	if (!device) {
		socket.emit('playQueue', { status: 'error', response: 'device not selected' });
		return;
	}

	Subsonic.queuePlaylist(id, device).then(() => {
		const song = Subsonic.getCurrentSong(device);
		Chromecast.play(device.friendlyName, song.id).then(() => {
			socket.emit('playQueue', { status: 'ok', response: song });
		});
	});

	device.on('finished', () => {
		const song = Subsonic.startNextSong(device);
		socket.emit('playQueue', song);

		for(const key in selectedChromecasts) {
			selectedChromecasts[key].socket.emit('playQueue', { status: 'ok', response: song });
		}

		Chromecast.play(device.friendlyName, song.id).then(() => {
			socket.emit('playQueue', { status: 'ok', response: { status: 'ok', response: song } });
		});
	});
}

export function playQueueShuffle(client: Client, uuid: string, id: string, socket: eventEmitter) {
	if (!selectedChromecasts[uuid]) {
		socket.emit('playQueue', { status: 'error', response: 'device not selected' });
		return;
	}

	const device = selectedChromecasts[uuid].device;

	if (!device) {
		socket.emit('playQueue', { status: 'error', response: 'device not selected' });
		return;
	}

	Subsonic.queuePlaylistShuffle(id, device).then(() => {
		const song = Subsonic.getCurrentSong(device);
		Chromecast.play(device.friendlyName, song.id).then(() => {
			for (const key in selectedChromecasts) {
				if(selectedChromecasts[key].device === device) {
					selectedChromecasts[key].socket.emit('playQueue', { status: 'ok', response: song });
				}
			}
		});
	});

	device.on('finished', () => {
		const song = Subsonic.startNextSong(device);

		Chromecast.play(device.friendlyName, song.id).then(() => {
			for (const key in selectedChromecasts) {
				if(selectedChromecasts[key].device === device) {
					selectedChromecasts[key].socket.emit('playQueue', { status: 'ok', response: song });
				}
			}
		});
	});
}

export function skip(client: Client, uuid: string, socket: eventEmitter) {
	if (!selectedChromecasts[uuid]) {
		socket.emit('playQueue', { status: 'error', response: 'device not selected' });
		return;
	}

	const device = selectedChromecasts[uuid].device;

	const song = Subsonic.startNextSong(device);
	if (song.index === -1) {
		return new Promise((resolve) => {
			resolve({ status: 'error', response: 'queue empty' });
		});
	}

	Chromecast.play(device.friendlyName, song.id);

	// Notify all UUIDs that selected this Chromecast that the song was skipped
	for (const key in selectedChromecasts) {
		if(selectedChromecasts[key].device === device) {
			selectedChromecasts[key].socket.emit('playQueue', { status: 'ok', response: song });
		}
	}
	return new Promise<string>((resolve) => {
		resolve(JSON.stringify({ status: 'ok', response: { status: 'ok', response: song } }));
	});
}

export function previous(client: Client, uuid: string, socket: eventEmitter) {
	if (!selectedChromecasts[uuid]) {
		socket.emit('playQueue', { status: 'error', response: 'device not selected' });
		return;
	}

	const device = selectedChromecasts[uuid].device;

	const song = Subsonic.startPreviousSong(device);

	Chromecast.play(device.friendlyName, song.id).then(() => {
		socket.emit('playQueue', { status: 'ok', response: song });
	});
}

export function seek(uuid: string, position: number, socket: eventEmitter) {
	if (!selectedChromecasts[uuid]) {
		socket.emit('playQueue', { status: 'error', response: 'device not selected' });
		return;
	}

	const device = selectedChromecasts[uuid].device;

	if (!device) {
		socket.emit('playQueue', { status: 'error', response: 'device not selected' });
		return;
	}

	device.seekTo(position, (err) => {
		if (err) {
			console.error(err);
			socket.emit('seek', { status: 'error', response: err });
		}
		device.getStatus((err, status) => {
			if (err) {
				socket.emit('seek', { status: 'error', response: err });
				return;
			}
			socket.emit('getStatus', { status: 'ok', response: {chromecastStatus: status, queue: Subsonic.getCurrentSong(device)} });
		});
	});
}

export function getCurrentSong(client: Client, uuid: string, socket: eventEmitter) {
	if (!selectedChromecasts[uuid]) {
		socket.emit('playQueue', { status: 'error', response: 'device not selected' });
		return;
	}

	const device = selectedChromecasts[uuid].device;

	if (!device) {
		socket.emit('playQueue', { status: 'error', response: 'device not found' });
		return;
	}

	socket.emit('playQueue', { status: 'ok', response: Subsonic.getCurrentSong(device) });
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
		socket.emit('getStatus', { status: 'ok', response: {chromecastStatus: status, queue: Subsonic.getCurrentSong(device)} });
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

			const song = Subsonic.getCurrentSong(device);

			socket.emit('getStatus', { status: 'ok', response: {chromecastStatus: status, queue: song} });
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

export function close(uuid: string, socket: eventEmitter) {
	if (!selectedChromecasts[uuid]) {
		socket.emit('playQueue', { status: 'error', response: 'device not selected' });
		return;
	}

	const device = selectedChromecasts[uuid].device;

	device.close(() => {

		socket.emit('close', { status: 'ok', response: 'closed' });
	});
}
