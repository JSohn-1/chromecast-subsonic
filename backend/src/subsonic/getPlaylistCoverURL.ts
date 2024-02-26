import { getPlaylist } from './getPlaylist';
import { generateURL } from './entry';

export function getPlaylistCoverURL(id: string) {
	return getPlaylist(id).then((_) => {
		if (_.status === 'ok') {
			return {status: 'ok', response: {id: id, url: generateURL('getCoverArt', new Map([['id', _.response.coverArt]]))}};
		}
		return {status: 'error', response: _.response};
	}).catch((err: string) => {
		return {status: 'error', response: err};
	});
}
