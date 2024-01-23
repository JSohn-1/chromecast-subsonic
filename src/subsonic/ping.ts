import { _requestHandler } from './entry';

export function ping() {
	return _requestHandler('ping', new Map()).then((_) => {
		const __ = JSON.parse(_);

		if (__['subsonic-response']['status'] === 'ok') {
			return JSON.stringify({ status: 'ok', response: 'pong' });
		}
		return JSON.stringify({ status: 'error', response: __['subsonic-response']['error']['message'] });
	}).catch((err: string) => {
		return JSON.stringify({ status: 'error', response: err });
	});
}