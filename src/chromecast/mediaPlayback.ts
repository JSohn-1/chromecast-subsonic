import { stream } from '../subsonic/stream';
// import { getChromecast } from './utilChromecast';

interface response {
	status: string,
	response: string
}

export function play(client: any, chromecastName: string, songId: string) {
	const device = client.devices.find((device: any) => device.friendlyName === chromecastName);

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
				device.play(media, (err: any) => {
					if (err) {
						console.error(err);
						reject({ status: 'error', response: err });
					}
					resolve({ status: 'ok', response: 'playing' });
				});
			}).catch((err: any) => {
				console.error(err);
				reject({ status: 'error', response: err });
			});
	});
}

export function pause(client: any, chromecastName: string) {
	const device = client.devices.find((device: any) => device.friendlyName === chromecastName);

	return new Promise<response>((resolve, reject) => {
		device.pause((err: any) => {
			if (err) {
				console.error(err);
				resolve({ status: 'error', response: err });
			}
			resolve({ status: 'ok', response: 'paused' });
		});
	});
}

export function resume(client: any, chromecastName: string) {
	const device = client.devices.find((device: any) => device.friendlyName === chromecastName);

	return new Promise<response>((resolve, reject) => {
		device.resume((err: any) => {
			if (err) {
				console.error(typeof err);
				resolve({ status: 'error', response: err });
			}
			resolve({ status: 'ok', response: 'resumed' });
		});
	});
}