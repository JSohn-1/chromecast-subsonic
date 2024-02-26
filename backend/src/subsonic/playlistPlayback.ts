import { getPlaylist } from './getPlaylist';

export function queuePlaylist(id: string) {
	getPlaylist(id).then((_) => {
		const songIds = _.response.songs.map((song: { id: string }) => song.id);
		return songIds;
	});
}
