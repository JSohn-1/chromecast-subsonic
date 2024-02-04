import { _requestHandler } from './entry';

export function getSong(id: string) {
	const map = new Map<string, string>();
	map.set('id', id);

	return _requestHandler('getSong', map).then((_) => {
		const __ = JSON.parse(_);
		if (__['subsonic-response'].status === 'ok') {
			return JSON.stringify({ status: 'ok', response: __['subsonic-response']['song'] });
		}
		return JSON.stringify({ status: 'error', response: __['subsonic-response']['error']['message'] });
	}).catch((err: string) => {
		return JSON.stringify({ status: 'error', response: err });
	});
}
