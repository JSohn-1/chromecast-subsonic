import Device = require('chromecast-api/lib/device');
import { chromecastDevice } from './chromecastDevice';

export enum playbackLocationType {
	LOCAL = 'LOCAL',
	CHROMECAST = 'CHROMECAST',
}

export class PlaybackLocation {
	type: playbackLocationType;
	device: Device | undefined;

	constructor(playbackLocation: Device | undefined) {
		this.type = playbackLocation ? playbackLocationType.CHROMECAST : playbackLocationType.LOCAL;
		this.device = playbackLocation;

		if (playbackLocation instanceof Device) {
			playbackLocation.on('finished', () => {
				this.type = playbackLocationType.LOCAL;
				this.device = undefined;
			});
		}
	}

	async play(title: string, mediaURL: string, coverURL: string) {
		if (!this.device) {
			throw new Error('No device connected');
		}

		return chromecastDevice.play(this.device, title, mediaURL, coverURL);
	}

	async pause() {
		if (!this.device) {
			throw new Error('No device connected');
		}

		return chromecastDevice.pause(this.device);
	}

	async resume() {
		if (!this.device) {
			throw new Error('No device connected');
		}

		return chromecastDevice.resume(this.device);
	}
}
