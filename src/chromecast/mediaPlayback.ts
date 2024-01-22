import { stream } from '../subsonic/stream';

import type Client = require('chromecast-api');

import { getChromecast, errorMessage } from './utilChromecast';

interface response {
	status: string,
	response: string
}

export function play(client: Client, chromecastName: string, songId: string) {
	const device = getChromecast(client, chromecastName);

	if (!device) {
		return new Promise<response>((resolve) => {
			resolve({ status: 'error', response: 'device not found' });
		});
	}

	return new Promise<response>((resolve, reject) => {
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
						resolve(errorMessage(err));
					}
					resolve({ status: 'ok', response: 'playing' });
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

	if (!device) {
		return new Promise<response>((resolve) => {
			resolve({ status: 'error', response: 'device not found' });
		});
	}

	return new Promise<response>((resolve) => {
		device.pause((err) => {
			if (err) {
				console.error(err);
				resolve(errorMessage(err));
			}
			resolve({ status: 'ok', response: 'paused' });
		});
	});
}

export function resume(client: Client, chromecastName: string) {
	const device = getChromecast(client, chromecastName);

	if (!device) {
		return new Promise<response>((resolve) => {
			resolve({ status: 'error', response: 'device not found' });
		});
	}

	return new Promise<response>((resolve) => {
		device.resume((err?: Error) => {
			if (err) {
				console.error(err);
				resolve(errorMessage(err));
			}
			resolve({ status: 'ok', response: 'resumed' });
		});
	});
}