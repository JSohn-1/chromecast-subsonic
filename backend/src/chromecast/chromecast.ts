// import ChromecastAPI from 'chromecast-api';

// import { EventEmitter } from 'events';
// import { getChromecasts, newChromecast } from './utilChromecast';
// import { play, pause, resume, playQueue, playQueueShuffle, skip, previous, seek, getCurrentSong, selectChromecast, getStatus, clearListener, close } from './mediaPlayback';

// export class Chromecast {
// 	static client = new ChromecastAPI();

// 	static newChromecast(socket: EventEmitter) { newChromecast(this.client, socket); }
// 	static getChromecasts() { return getChromecasts(this.client); }
// 	static play(chromecastName: string, songId: string) { return play(this.client, chromecastName, songId); }
// 	static pause(uuid: string) { return pause(this.client, uuid); }
// 	static resume(uuid: string) { return resume(this.client, uuid); }
// 	static playQueue(uuid: string, id: string, socket: EventEmitter) { return playQueue(this.client, uuid, id, socket); }
// 	static playQueueShuffle(uuid: string, id: string, socket: EventEmitter) { return playQueueShuffle(this.client, uuid, id, socket); }
// 	static skip(uuid: string, socket: EventEmitter) { return skip(this.client, uuid, socket); }
// 	static previous(uuid: string, socket: EventEmitter) { return previous(this.client, uuid, socket); }
// 	static getCurrentSong(uuid: string, socket: EventEmitter) { return getCurrentSong(this.client, uuid, socket); }
// 	static selectChromecast(chromecastName: string, uuid: string, socket: EventEmitter) { return selectChromecast(this.client, chromecastName, uuid, socket); }
// 	static getStatus(uuid: string, socket: EventEmitter) { return getStatus(this.client, uuid, socket); }
// 	static clearListener = clearListener;
// 	static close = close;
// 	static seek = seek;
// }
