// import Device = require('chromecast-api/lib/device');
// import { chromecastDevice } from './chromecastDevice';
import { Local } from './local';
// import { playback } from '../routes/subsonic/playback';

export enum playbackLocationType {
	LOCAL = 'LOCAL',
	CHROMECAST = 'CHROMECAST',
}

export class PlaybackLocation {
	type: playbackLocationType;
	name: string;
	device: Local;

	constructor(playbackLocation: Local, name: string) {
		this.type = playbackLocationType.LOCAL;
		this.device = playbackLocation;
		this.name = name;

		// if (playbackLocation instanceof Device) {
		// 	playbackLocation.on('finished', () => {
		// 		this.type = playbackLocationType.LOCAL;
		// 		this.device = undefined;
		// 	});
		// }
	}

	async play(id: string) {
		if (!this.device) {
			throw new Error('No device connected');
		}

		this.device.play(id);
	}

	async pause() {
		if (!this.device) {
			throw new Error('No device connected');
		}
		this.device.pause();
	}

	async resume() {
		if (!this.device) {
			throw new Error('No device connected');
		}
		this.device.resume();
	}
}
