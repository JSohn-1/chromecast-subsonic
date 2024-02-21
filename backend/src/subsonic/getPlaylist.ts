import { _requestHandler } from './entry';

export function getPlaylist(id: string) {
	const map = new Map<string, string>();
	map.set('id', id);

	return _requestHandler('getPlaylist', map).then((_) => {
		const __ = JSON.parse(_);
		if (__['subsonic-response']['status'] === 'ok') {
			return { status: 'ok', response: __['subsonic-response']['playlist'] };
		}
		return { status: 'error', response: __['subsonic-response']['error']['message'] };
	}).catch((err: string) => {
		return { status: 'error', response: err };
	});
}
