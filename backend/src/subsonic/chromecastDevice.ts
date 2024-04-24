import Device = require('chromecast-api/lib/device');

export class chromecastDevice {
	device: Device;

	constructor(Device: Device) {
		this.device = Device;
	}

	async play(title: string, mediaURL: string, coverURL: string) {
		const media = {
			url: mediaURL,
			cover: {
				title: title,
				url: coverURL,
			},
		};
		
		this.device.play(media, (err?: Error) => {
			if (err) {
				return { status: 'error', response: `${err.name}: ${err.message}` };
			}
			return { status: 'ok', response: 'playing' };
		});
	}

	async pause() {
		const response = await this.device.pause();
		return response;
	}

	async resume(){
		this.device.resume((err?: Error) => {
			if (!err) {
				return { status: 'ok', response: 'resumed' };
			}
			return { status: 'error', response: `${err.name}: ${err.message}` };
		});
	}
}
