import { Subsonic } from './subsonic';
import { PlayQueue } from './playQueue';
import { Notify } from './notify';

import Device from 'chromecast-api/lib/device';

export enum playbackMode {
	LOOP = 'LOOP',
	REPEAT = 'REPEAT',
	RECOMMEND = 'RECOMMEND',
}

export class Playback {
	static users: { [username: string]: {playback: Playback, api: Subsonic}} = {};

	user: Subsonic;
	playQueue: PlayQueue;
	device?: Device;
	mode: playbackMode = playbackMode.REPEAT;

	static savePlayback(user: Subsonic) {
		if (Playback.users[user.username]) {
			return;
		}
		Playback.users[user.username] = { playback: new Playback(user), api: user };
	}

	constructor(user: Subsonic) {
		this.user = user;
		this.playQueue = new PlayQueue(user);
	}
	
	async playPlaylist(playlistId: string, shuffle?: boolean) {
		if (!this.device) {
			throw new Error('No device connected');
		}

		const playlist = (await this.user.getPlaylist({ id: playlistId })).playlist;

		await this.playQueue.queuePlaylist(playlist, shuffle);

		const song = this.playQueue.nextSong;

		this.device?.play(this.user.stream({id: song.id}));
		
		Notify.notifyUsers(this.user.username, 'playQueue',  song); 

		this.device?.on('finished', () => {
			const song = this.playQueue.nextSong;
			if(song.index === -1) {
				this.device?.removeAllListeners('finished');
				Notify.notifyUsers(this.user.username, 'playQueue',  { id: '', index: -1 });
				return;
			}
			this.device?.play(this.user.stream({id: song.id }));
			Notify.notifyUsers(this.user.username, 'playQueue',  song);
		});
	}

	playSong(songId: string, addToQueue?: boolean) {
		if (!this.device) {
			throw new Error('No device connected');
		}

		this.playQueue.addSong(songId, addToQueue);

		if (this.device.listenerCount('finished') === 0) {
			const song = this.playQueue.nextSong;
			this.device?.play(this.user.stream(song));
			Notify.notifyUsers(this.user.username, 'playQueue',  song);

			this.device?.on('finished', () => {
				const song = this.playQueue.nextSong;
				if(song.index === -1) {
					this.device?.removeAllListeners('finished');
					Notify.notifyUsers(this.user.username, 'playQueue',  { id: '', index: -1 });
					return;
				}
				this.device?.play(this.user.stream({id: song.id }));
				Notify.notifyUsers(this.user.username, 'playQueue',  song);
			});
		}
	}

	skip() {
		if (!this.device) {
			throw new Error('No device connected');
		}

		const song = this.playQueue.nextSong;

		if(song.index !== -1) {
			this.device?.play(this.user.stream(song));
			Notify.notifyUsers(this.user.username, 'playQueue',  song);
		}
	}

	async previousSong() {
		if (!this.device) {
			throw new Error('No device connected');
		}

		const song = this.playQueue.previousSong;

		if(song.index !== -1) {
			this.device?.play(this.user.stream(song));
			Notify.notifyUsers(this.user.username, 'playQueue',  song);
		}
	}
}
