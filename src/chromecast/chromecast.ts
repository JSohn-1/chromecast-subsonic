import ChromecastAPI from 'chromecast-api';
import { EventEmitter } from 'events';
import { getChromecasts } from './utilChromecast';
import { play, pause, resume, subscribe, unsubscribe } from './mediaPlayback';

export class Chromecast {
	static client = new ChromecastAPI();

	// static init() {
	// 	return new Promise<void>((resolve) => {
	// 		this.client.on('device', () => {
	// 			resolve();
	// 		});
	// 	});
	// }

	static newChromecast(socket: EventEmitter) {
		this.client.on('device', (device) => {
			socket.emit('newChromecast', device.friendlyName);
		});
	}

	static getChromecasts() { return getChromecasts(this.client); }
	static play(chromecastName: string, songId: string) { return play(this.client, chromecastName, songId); }
	static pause(chromecastName: string) { return pause(this.client, chromecastName); }
	static resume(chromecastName: string) { return resume(this.client, chromecastName); }
	static subscribe(chromecastName: string, socket: EventEmitter) { return subscribe(this.client, chromecastName, socket); }
	static unsubscribe(chromecastName: string, socket: EventEmitter) { return unsubscribe(this.client, chromecastName, socket); }
}
