import { Socket } from 'socket.io';

import { Subsonic } from './subsonic';
import { PlayQueue } from './playQueue';
import { Notify } from './notify';
import { PlaybackLocation, playbackLocationType } from './playbackLocation';

// import Device from 'chromecast-api/lib/device';
import { Local } from './local';
import { Sockets } from '../routes/eventHandler';

export enum playbackMode {
	LOOP = 'LOOP',
	REPEAT = 'REPEAT',
	RECOMMEND = 'RECOMMEND',
}

export class Playback {
	static users: { [username: string]: {playback: Playback, api: Subsonic}} = {};

	user: Subsonic;
	playQueue: PlayQueue;
	playbackLocation: PlaybackLocation | undefined;
	playbackLocations: PlaybackLocation[] = [];
	mode: playbackMode = playbackMode.REPEAT;

	static savePlayback(user: Subsonic, name: string, socket: Socket) {
		if (Playback.users[user.username]) {
			if (Playback.users[user.username].playback.playbackLocation === undefined) {
				Playback.users[user.username].playback.setLocation(new Local(socket), name);
			}
			Playback.users[user.username].playback.playbackLocations.push(new PlaybackLocation(new Local(socket), name));

			return;
		}
		Playback.users[user.username] = { playback: new Playback(user, socket), api: user };
		Playback.users[user.username].playback.playbackLocations.push(new PlaybackLocation(new Local(socket), name));
	}

	constructor(user: Subsonic, socket: Socket) {
		this.user = user;
		this.playQueue = new PlayQueue(user);
		this.playbackLocation = new PlaybackLocation(new Local(socket), 'Local');
	}

	setLocation(location: Local, name: string) {
		this.playbackLocation = new PlaybackLocation(location, name);
	}
	
	async playPlaylist(playlistId: string, socketId: string, shuffle?: boolean,) {
		// if(this.playbackLocation === undefined) {
		// 	throw new Error('No playback location');
		// }

		if (this.playbackLocation === undefined) {
			const socket = Sockets.sockets[socketId].socket;
			this.playbackLocation = new PlaybackLocation(new Local(socket), Sockets.sockets[socketId].name as string);
		}

		// console.log('Playing playlist');

		const playlist = (await this.user.getPlaylist({ id: playlistId })).playlist;

		await this.playQueue.queuePlaylist(playlist, shuffle);

		// if (this.playbackLocation === undefined) {
		// 	this.playbackLocation = new PlaybackLocation(new Local(socket), name);
		// }
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
		if (this.playbackLocation === undefined) {
			throw new Error('No playback location');
		}

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
		if (this.playbackLocation === undefined) {
			throw new Error('No playback location');
		}

		this.playQueue.userQueue.index = index;
		const song = this.playQueue.userQueue.queue[index];

		Notify.notifyUsers(this.user.username, 'playQueue', { id: song, index: index, uuid: this.playbackLocation.device, name: this.playbackLocation.name });
	}

	// next() {
	// 	const song = this.playQueue.nextSong;
	// 	const device = this.playbackLocation.device!;

	// 	if(song.index !== -1) {
	// 		device.play(song.id);
	// 		Notify.notifyUsers(this.user.username, 'playQueue',  song);
	// 	}
	// }

	// previous() {
	// 	const song = this.playQueue.previousSong;
	// 	const device = this.playbackLocation.device!;

	// 	if(song.index !== -1) {
	// 		device.play(song.id);
	// 		Notify.notifyUsers(this.user.username, 'playQueue',  song);
	// 	}
	// }

	pause(socketId: string) {
		if (this.playbackLocation === undefined) {
			throw new Error('No playback location');
		}

		this.playbackLocation.pause();
		Notify.notifyUsers(this.user.username, 'pause', {}, socketId);
	}

	resume(socketId: string) {
		// if (this.playbackLocation === undefined) {
		// 	throw new Error('No playback location');
		// }

		if (this.playbackLocation === undefined) {
			const socket = Sockets.sockets[socketId].socket;
			this.playbackLocation = new PlaybackLocation(new Local(socket), Sockets.sockets[socketId].name as string);

			socket.emit('setLocation', socketId, true);
		}

		this.playbackLocation.resume();
		Notify.notifyUsers(this.user.username, 'resume', {}, socketId);
	}

	changePlaybackLocation(socketId: string): { success: boolean, message: string } {
		const location = this.playbackLocations.find((location) => location.device.socket.id === socketId);

		if (location === undefined) {
			return {'success': false, 'message': 'Location not found'};
		}

		this.playbackLocation = location;

		const socket = location.device!.socket;

		socket.emit('setLocation', socketId, true);
		return {'success': true, 'message': 'Location changed'};
	}

	static disconnect(socket: Socket) {
		if (Subsonic.apis[socket.id] === undefined) {
			return;
		}

		const username = Subsonic.apis[socket.id].username;
		
		Playback.users[username].playback.playbackLocations = Playback.users[username].playback.playbackLocations.filter((location) => location.device!.socket.id !== socket.id);

		if (Playback.users[username].playback.playbackLocation === undefined) {
			throw new Error('No playback location');
		}

		if (Playback.users[username].playback.playbackLocation!.type != playbackLocationType.LOCAL) {
			return;
		}

		if (Playback.users[username].playback.playbackLocation!.device!.socket.id === socket.id) {
			Playback.users[username].playback.playbackLocation = undefined;
		}
	}

	toJSON() {
		if (this.playbackLocation === undefined) {
			throw new Error('No playback location');
		}
		return {
			playQueue: this.playQueue,
			playbackLocation: this.playbackLocation.device?.toJSON() ?? { state: 'STOPPED', uuid: '' },
			mode: this.mode,
		};
	}
}
