import Device = require('chromecast-api/lib/device');

export class chromecastDevice {
	static async play(device: Device, title: string, mediaURL: string, coverURL: string) {
		const media = {
			url: mediaURL,
			cover: {
				title: title,
				url: coverURL,
			},
		};

		let response: unknown = device.play(media, (err?: Error) => {
			if (err) {
				response = { status: 'error', response: `${err.name}: ${err.message}` };
			}
			response = { status: 'ok', response: 'playing' };
		});

		return response;
	}

	static async pause(device: Device) {
		const response = device.pause((err?: Error) => {
			if (err) {
				return { status: 'error', response: `${err.name}: ${err.message}` };
			}
			return { status: 'ok', response: 'paused' };
		});
		return response;
	}

	static async resume(device: Device){
		device.resume((err?: Error) => {
			if (!err) {
				return { status: 'ok', response: 'resumed' };
			}
			return { status: 'error', response: `${err.name}: ${err.message}` };
		});
	}
}
