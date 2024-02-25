import { ping } from './ping';
import { getPlaylists } from './getPlaylists';
import { getPlaylist } from './getPlaylist';
import { getSong } from './getSong';
import { getSongInfo } from './getSongInfo';
import { getPlaylistCoverURL } from './getPlaylistCoverURL';

import { EventEmitter } from 'events';
import type Device = require('chromecast-api/lib/device');

export class Subsonic {
	static ping = ping;
	static getPlaylists = getPlaylists;
	static getPlaylist = getPlaylist;
	static getSong = getSong;
	static getSongInfo = getSongInfo;
	static getPlaylistCoverURL = getPlaylistCoverURL;

	static serverQueue: { [deviceName: string]: {index: number, queue: string[]} } = {};

	static queuePlaylist(id: string, device: Device) {
		return new Promise((resolve) => {
			getPlaylist(id).then((_) => {
				const playlist = _
				const queue = {index: 0, queue: playlist.response.entry.map((song: { id: string }) => song.id)};
				Subsonic.serverQueue[device.name] = queue;
				resolve({status: 'ok', response: 'queued'});
			});
		});
	}

	static queuePlaylistShuffle(id: string, device: Device) {
		return new Promise((resolve) => {
			getPlaylist(id).then((_) => {
				const playlist = _
				const queue = {index: 0, queue: playlist.response.entry.map((song: { id: string }) => song.id).sort(() => Math.random() - 0.5)};

				Subsonic.serverQueue[device.name] = queue;
				resolve({status: 'ok', response: 'queued'});
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

		if (index < queue.length - 1) {
			Subsonic.serverQueue[name].index++;
			return { id: queue[Subsonic.serverQueue[name].index++], index: Subsonic.serverQueue[name].index++ };
		}

		if (index === queue.length - 1) {
			Subsonic.serverQueue[name].index = 0;
			return { id: queue[0], index: 0 };
		}


		return { id: '', index: -1 };
	}

	static startPreviousSong(device: Device) {
		const name = device.name;
		if (!Subsonic.serverQueue[name]) {
			return { id: '', index: -1 };
		}

		const queue = Subsonic.serverQueue[name].queue;
		const index = Subsonic.serverQueue[name].index;

		if (index > 0) {
			Subsonic.serverQueue[name].index--;
			return { id: queue[Subsonic.serverQueue[name].index - 2], index: Subsonic.serverQueue[name].index - 2 };
		}

		if (index === 0) {
			Subsonic.serverQueue[name].index = queue.length - 1;
			return { id: queue[queue.length - 1], index: queue.length - 1 };
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

		return { id: queue[index], index: index };
	}

	static getQueue(device: Device) {
		const name = device.name;

		if (!Subsonic.serverQueue[name]) {
			return { queue: [], index: -1 };
		}

		const queue = Subsonic.serverQueue[name].queue;
		const index = Subsonic.serverQueue[name].index;

		return { queue: queue, index: index };
	}
}
