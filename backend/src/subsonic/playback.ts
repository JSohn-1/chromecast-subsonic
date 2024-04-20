import { Subsonic } from './subsonic';
import { PlayQueue } from './playQueue';

import Device from 'chromecast-api/lib/device';

export enum playbackMode {
	LOOP = 'LOOP',
	REPEAT = 'REPEAT',
	RECOMMEND = 'RECOMMEND',
}

export class Playback {
	user: Subsonic;
	playQueue: PlayQueue;
	device?: Device;
	mode: playbackMode = playbackMode.REPEAT;

	constructor(user: Subsonic) {
		this.user = user;
		this.playQueue = new PlayQueue(user);
	}
	
	async playPlaylist(playlistId: string, shuffle?: boolean) {
		const playlist = await this.user.getPlaylist(playlistId);
		await this.playQueue.queuePlaylist(playlist, shuffle);
	}

	async playSong(songId: string) {
		await this.playQueue.queueSong(songId);
	}

	async nextSong() {
		if (!this.device) {
			throw new Error('No device connected');
		}

		const id = await this.playQueue.nextSong;

		this.device?.play(id);
	}

	async previousSong() {
		return await this.playQueue.previousSong;
	}
}