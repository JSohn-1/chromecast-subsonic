import { ping } from './ping';
import { getPlaylists } from './getPlaylists';
import { getPlaylist } from './getPlaylist';
import { getSong } from './getSong';
import { getSongInfo } from './getSongInfo';

export class Subsonic {
	static ping = ping;
	static getPlaylists = getPlaylists;
	static getPlaylist = getPlaylist;
	static getSong = getSong;
	static getSongInfo = getSongInfo;

	static queue: string[] = [];
	static index: number = 0;
	static queuePlaylist(id: string) {
		Subsonic.queue = [];

		return new Promise<string>((resolve) => {
			getPlaylist(id).then((_: string) => {
				const playlist = JSON.parse(_);
				Subsonic.queue = playlist.response.entry.map((song: { id: string }) => song.id);
				resolve('ok');
			});
		});
	}

	static startNextSong() {
		if (Subsonic.index < Subsonic.queue.length) {
			Subsonic.index++;
			return { id: Subsonic.queue[Subsonic.index - 1], index: Subsonic.index - 1 };
		}

		if (Subsonic.index === Subsonic.queue.length) {
			Subsonic.index = 0;
			Subsonic.index++;
			return { id: Subsonic.queue[Subsonic.index - 1], index: Subsonic.index - 1 };
		}

		return { id: '', index: -1 };
	}

	static startSong(index: number) {
		if (index < Subsonic.queue.length) {
			Subsonic.index = index;
			return { id: Subsonic.queue[Subsonic.index], index: Subsonic.index };
		}

		return { id: '', index: -1 };
	}

	static getCurrentSong() {
		if (this.queue.length == 0){
			return { id: '', index: -1 };
		}

		return { id: Subsonic.queue[Subsonic.index - 1], index: Subsonic.index - 1 };
	}
}
