import { getPlaylist } from './getPlaylist';

export function queuePlaylist(id: string) {
	getPlaylist(id).then((_: string) => {
		const playlist = JSON.parse(_);
		const songIds = playlist.songs.map((song: { id: string }) => song.id);
		return songIds;
	});
}
