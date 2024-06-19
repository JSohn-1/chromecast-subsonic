import { Socket } from 'socket.io';

import { Subsonic } from './subsonic';
import { PlayQueue } from './playQueue';
import { Notify } from './notify';
import { PlaybackLocation, playbackLocationType } from './playbackLocation';

// import Device from 'chromecast-api/lib/device';
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
			if (Playback.users[user.username].playback.playbackLocation.type === undefined) {
				Playback.users[user.username].playback.setLocation(new Local(socket));
			}

			return;
		}
		Playback.users[user.username] = { playback: new Playback(user, socket), api: user };
	}

	constructor(user: Subsonic, socket: Socket) {
		this.user = user;
		this.playQueue = new PlayQueue(user);
		this.playbackLocation = new PlaybackLocation(new Local(socket), 'Local');
	}

	setLocation(location: Local | undefined) {
		this.playbackLocation = new PlaybackLocation(location);
	}
	
	async playPlaylist(socket: Socket, playlistId: string, shuffle?: boolean,) {
		// console.log('Playing playlist');

		const playlist = (await this.user.getPlaylist({ id: playlistId })).playlist;

		await this.playQueue.queuePlaylist(playlist, shuffle);

		if (this.playbackLocation.device === undefined) {
			this.playbackLocation = new PlaybackLocation(new Local(socket));
		}
		// const song = this.playQueue.nextSong;
		const song = this.playQueue.userQueue.queue[0];

		this.playbackLocation.play(song);
		
		// console.log('Playing playlist', song);

		// console.log(this);

		Notify.notifyUsers(this.user.username, 'changeQueue', this.playQueue);
		Notify.notifyUsers(this.user.username, 'playQueue', { id: song, index: this.playQueue.userQueue.index, uuid: this.playbackLocation.device, name: this.playbackLocation.name });  

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

	setIndex(index: number) {
		this.playQueue.userQueue.index = index;
		const song = this.playQueue.userQueue.queue[index];

		Notify.notifyUsers(this.user.username, 'playQueue', { id: song, index: index, uuid: this.playbackLocation.device, name: this.playbackLocation.name });
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

	pause(socketId: string) {
		this.playbackLocation.pause();
		Notify.notifyUsers(this.user.username, 'pause', {}, socketId);
	}

	resume(socketId: string) {
		this.playbackLocation.resume();
		Notify.notifyUsers(this.user.username, 'resume', {}, socketId);
	}

	static disconnect(socket: Socket) {
		if (Subsonic.apis[socket.id] === undefined) {
			return;
		}

		const username = Subsonic.apis[socket.id].username;
		
		if (Playback.users[username].playback.playbackLocation.type != playbackLocationType.LOCAL) {
			return;
		}

		if (Playback.users[username].playback.playbackLocation.device!.socket.id === socket.id) {
			Playback.users[username].playback.setLocation(undefined);
		}
	}

	toJSON() {
		return {
			playQueue: this.playQueue,
			playbackLocation: this.playbackLocation.device?.toJSON() ?? { state: 'STOPPED', uuid: '' },
			mode: this.mode,
		};
	}
}
