import { ping } from './ping';
import { getPlaylists } from './getPlaylists';
import { getPlaylist } from './getPlaylist';
import { getSong } from './getSong';
import { getSongInfo } from './getSongInfo';
import { EventEmitter } from 'events';
import type Device = require('chromecast-api/lib/device');

export class Subsonic {
	static ping = ping;
	static getPlaylists = getPlaylists;
	static getPlaylist = getPlaylist;
	static getSong = getSong;
	static getSongInfo = getSongInfo;

	static serverQueue: { [deviceName: string]: {index: number, queue: string[]} } = {};
	static index: number = 0;
	static queuePlaylist(id: string, device: Device) {
		return new Promise<string>((resolve) => {
			getPlaylist(id).then((_) => {
				const playlist = JSON.parse(_);
				const queue = {index: 0, queue: playlist.response.entry.map((song: { id: string }) => song.id)};

				Subsonic.serverQueue[device.name] = queue;
				resolve('ok');
			});
		});
	}

	static startNextSong(device: Device) {
		const name = device.name;

		if (!Subsonic.serverQueue[name]) {
			return { id: '', index: -1 };
		}

		const queue = Subsonic.serverQueue[name].queue;
		const index = Subsonic.serverQueue[name].index;

		if (index < queue.length) {
			Subsonic.serverQueue[name].index++;
			return { id: queue[index], index: index };
		}

		if (index === queue.length) {
			Subsonic.serverQueue[name].index = 0;
			Subsonic.serverQueue[name].index++;
			return { id: queue[0], index: 0 };
		}


		return { id: '', index: -1 };
	}

	static startSong(index: number, device: Device) {
		const name = device.name;
		const queue = Subsonic.serverQueue[name].queue;

		if (index < queue.length) {
			Subsonic.serverQueue[name].index = index;
			return { id: queue[index], index: index };
		}

		return { id: '', index: -1 };
	}

	static getCurrentSong(device: Device) {
		const name = device.name;

		if (!Subsonic.serverQueue[name]) {
			return { id: '', index: -1 };
		}

		const queue = Subsonic.serverQueue[name].queue;
		const index = Subsonic.serverQueue[name].index;

		if (queue.length == 0){
			return { id: '', index: -1 };
		}

		return { id: queue[index - 1], index: index - 1 };
	}
}
