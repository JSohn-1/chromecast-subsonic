// import Device from 'chromecast-api/lib/device';

import { Subsonic } from './subsonic';

import { SubsonicPlaylistInfo, subsonicPlaylist, subsonicSong } from './types';

import { playbackMode } from './playback';

export class PlayQueue{
	
	user: Subsonic;
	userQueue: { index: number, queue: string[], playlist?: SubsonicPlaylistInfo };
	mode: playbackMode = playbackMode.REPEAT;

	constructor(user: Subsonic) {
		this.user = user;
		this.userQueue = { index: -1, queue: [] };
	}

	async queuePlaylist(playlist: subsonicPlaylist, shuffle?: boolean) {
		let songs = playlist.entry.map((song: subsonicSong) => song.id);

		if (shuffle) {
			// eslint-disable-next-line no-magic-numbers
			songs = songs.sort(() => Math.random() - 0.5);
		}

		this.userQueue = {index: 0, queue: songs, playlist: {id: playlist.id, name: playlist.name}};
	} 

	addSong(songId: string, addToQueue?: boolean) {
		if (!addToQueue) {
			this.userQueue = {index: 0, queue: [songId]};
			return;
		}

		this.userQueue.queue.push(songId);
	}

	get nextSong() {
		if (this.userQueue.index === -1) {
			return { id: '', index: -1 };
		}

		const queue = this.userQueue.queue;
		const index = this.userQueue.index;

		if (index < queue.length - 1) {
			this.userQueue.index++;
			return { id: queue[index + 1], index: index + 1};
		}

		if (index === queue.length - 1 && this.mode === playbackMode.LOOP) {
			this.userQueue.index = 0;
			return { id: queue[0], index: 0 };
		}

		return { id: '', index: -1 };
	}

	get previousSong() {
		if (this.userQueue.index === -1) {
			return { id: '', index: -1 };
		}

		const queue = this.userQueue.queue;
		const index = this.userQueue.index;

		if (index > 0) {
			this.userQueue.index--;
			return { id: queue[index - 1], index: index - 1};
		}

		if (index === 0) {
			this.userQueue.index = queue.length - 1;
			return { id: queue[queue.length - 1], index: queue.length - 1 };
		}

		return { id: '', index: -1 };
	}

	get getQueue() {
		return this.userQueue;
	}
}
