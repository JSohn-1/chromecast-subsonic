import { ping } from './ping';
import { getPlaylists } from './getPlaylists';
import { getPlaylist } from './getPlaylist';
import { getSong } from './getSong';

export class Subsonic {
	static ping = ping;
	static getPlaylists = getPlaylists;
	static getPlaylist = getPlaylist;
	static getSong = getSong;
}
