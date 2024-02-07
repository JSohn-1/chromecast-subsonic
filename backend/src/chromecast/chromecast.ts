import ChromecastAPI from 'chromecast-api';

import { EventEmitter } from 'events';
import { getChromecasts } from './utilChromecast';
import { play, pause, resume, subscribe, unsubscribe, playQueue, skip, getCurrentSong } from './mediaPlayback';

export class Chromecast {
	static client = new ChromecastAPI();

	static newChromecast(socket: EventEmitter) { return this.client.on('device', (device) => socket.emit('newChromecast', device.friendlyName)); }
	static getChromecasts() { return getChromecasts(this.client); }
	static play(chromecastName: string, songId: string) { return play(this.client, chromecastName, songId); }
	static pause(chromecastName: string) { return pause(this.client, chromecastName); }
	static resume(chromecastName: string) { return resume(this.client, chromecastName); }
	static subscribe(chromecastName: string, uuid: string, socket: EventEmitter) { return subscribe(this.client, chromecastName, uuid, socket); }
	static unsubscribe(chromecastName: string, uuid: string, socket: EventEmitter) { return unsubscribe(this.client, chromecastName, uuid, socket); }
	static playQueue(chromecastName: string, id: string, socket: EventEmitter) { return playQueue(this.client, id, chromecastName, socket); }
	static skip(chromecastName: string, socket: EventEmitter) { return skip(this.client, chromecastName, socket); }
	static getCurrentSong(chromecastName: string, socket: EventEmitter) { return getCurrentSong(this.client, chromecastName, socket); }
}
