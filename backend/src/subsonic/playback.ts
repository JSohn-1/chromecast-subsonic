import { Socket } from 'socket.io';

import { Subsonic } from './subsonic';
import { PlayQueue } from './playQueue';
import { Notify } from './notify';
import { PlaybackLocation } from './playbackLocation';

import Device from 'chromecast-api/lib/device';
import { Local } from './local';

export enum playbackMode {
	LOOP = 'LOOP',
	REPEAT = 'REPEAT',
	RECOMMEND = 'RECOMMEND',
}

export class Playback {
	static users: { [username: string]: {playback: Playback, api: Subsonic}} = {};

	user: Subsonic;
	playQueue: PlayQueue;
	playbackLocation: PlaybackLocation;
	mode: playbackMode = playbackMode.REPEAT;

	static savePlayback(user: Subsonic, socket: Socket) {
		if (Playback.users[user.username]) {
			return;
		}
		Playback.users[user.username] = { playback: new Playback(user, socket), api: user };
	}

	constructor(user: Subsonic, socket: Socket) {
		this.user = user;
		this.playQueue = new PlayQueue(user);
		this.playbackLocation = new PlaybackLocation(new Local(socket));
	}

	setLocation(location: Device | Local | undefined) {
		this.playbackLocation = new PlaybackLocation(location);
	}
	
	async playPlaylist(playlistId: string, shuffle?: boolean) {
		console.log('Playing playlist');

		const playlist = (await this.user.getPlaylist({ id: playlistId })).playlist;

		await this.playQueue.queuePlaylist(playlist, shuffle);

		const song = this.playQueue.nextSong;

		this.playbackLocation.play(song.id);
		
		Notify.notifyUsers(this.user.username, 'playQueue', { id: song.id });  

		// if (this.playbackLocation.type === playbackLocationType.CHROMECAST) {
		// 	const device = this.playbackLocation.device!;
			
		// 	device.on('finished', () => {
		// 		const song = this.playQueue.nextSong;
		// 		if(song.index === -1) {
		// 			device.removeAllListeners('finished');
		// 			Notify.notifyUsers(this.user.username, 'playQueue',  { id: '', index: -1 });
		// 			return;
		// 		}
		// 		device.play(this.user.stream({id: song.id }));
		// 		Notify.notifyUsers(this.user.username, 'playQueue',  song);
		// 	});
		// }
	}

	playSong(songId: string, addToQueue?: boolean) {
		this.playQueue.addSong(songId, addToQueue);

		const device = this.playbackLocation.device!;
		const song = this.playQueue.nextSong;

		device.play(song.id);
		Notify.notifyUsers(this.user.username, 'playQueue',  song);

		// device.on('finished', () => {
		// 	const song = this.playQueue.nextSong;
		// 	if(song.index === -1) {
		// 		device.removeAllListeners('finished');
		// 		Notify.notifyUsers(this.user.username, 'playQueue',  { id: '', index: -1 });
		// 		return;
		// 	}
		// 	device.play(song.id);
		// 	Notify.notifyUsers(this.user.username, 'playQueue',  song);
		// });
		
	}

	next() {
		const song = this.playQueue.nextSong;
		const device = this.playbackLocation.device!;

		if(song.index !== -1) {
			device.play(song.id);
			Notify.notifyUsers(this.user.username, 'playQueue',  song);
		}
	}

	previous() {
		const song = this.playQueue.previousSong;
		const device = this.playbackLocation.device!;

		if(song.index !== -1) {
			device.play(song.id);
			Notify.notifyUsers(this.user.username, 'playQueue',  song);
		}
	}
}
