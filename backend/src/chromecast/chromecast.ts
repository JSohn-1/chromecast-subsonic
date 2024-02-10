import ChromecastAPI from 'chromecast-api';

import { EventEmitter } from 'events';
import { getChromecasts } from './utilChromecast';
import { play, pause, resume, subscribe, unsubscribe, playQueue, skip, getCurrentSong, selectChromecast } from './mediaPlayback';

export class Chromecast {
	static client = new ChromecastAPI();

	static newChromecast(socket: EventEmitter) { return this.client.on('device', (device) => socket.emit('newChromecast', device.friendlyName)); }
	static getChromecasts() { return getChromecasts(this.client); }
	static play(chromecastName: string, songId: string) { return play(this.client, chromecastName, songId); }
	static pause(uuid: string) { return pause(this.client, uuid); }
	static resume(uuid: string) { return resume(this.client, uuid); }
	static subscribe(chromecastName: string, uuid: string, socket: EventEmitter) { return subscribe(this.client, chromecastName, uuid, socket); }
	static unsubscribe(chromecastName: string, uuid: string, socket: EventEmitter) { return unsubscribe(this.client, chromecastName, uuid, socket); }
	static playQueue(uuid: string, id: string, socket: EventEmitter) { return playQueue(this.client, uuid, id, socket); }
	static skip(uuid: string, socket: EventEmitter) { return skip(this.client, uuid, socket); }
	static getCurrentSong(uuid: string, socket: EventEmitter) { return getCurrentSong(this.client, uuid, socket); }
	static selectChromecast(chromecastName: string, uuid: string, socket: EventEmitter) { return selectChromecast(this.client, chromecastName, uuid, socket); }
}
