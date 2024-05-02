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
		
		device.play(media, (err?: Error) => {
			if (err) {
				return { status: 'error', response: `${err.name}: ${err.message}` };
			}
			return { status: 'ok', response: 'playing' };
		});
	}

	static async pause(device: Device) {
		const response = await device.pause();
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
