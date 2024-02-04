import { _requestHandler } from './entry';

export function getPlaylists() {
	return _requestHandler('getPlaylists', new Map()).then((_) => {
		const __ = JSON.parse(_);
		if (__['subsonic-response']['status'] === 'ok') {
			return JSON.stringify({ status: 'ok', response: __['subsonic-response']['playlists']['playlist'] });
		}
		return JSON.stringify({ status: 'error', response: __['subsonic-response']['error']['message'] });
	}).catch((err: string) => {
		return JSON.stringify({ status: 'error', response: err });
	});
}
