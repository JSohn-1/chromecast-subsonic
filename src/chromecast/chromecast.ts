import ChromecastAPI from 'chromecast-api';

import { getChromecasts } from './utilChromecast';
import { play, pause, resume } from './mediaPlayback';

export class Chromecast {
	static client = new ChromecastAPI();

	static init() {
		return new Promise<void>((resolve, reject) => {
			this.client.on('device', (device: any) => {
				resolve();
			});
			this.client.on('error', (error: any) => {
				reject(error);
			});

		});
	}

	static getChromecasts() { return getChromecasts(this.client) };
	static play(chromecastName: string, songId: string) { return play(this.client, chromecastName, songId) };
	static pause(chromecastName: string) { return pause(this.client, chromecastName) };
	static resume(chromecastName: string) { return resume(this.client, chromecastName) };
}