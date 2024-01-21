import { _requestHandler } from './entry';

export function ping() {
	return _requestHandler('ping', new Map()).then((_: JSON) => {
		if ((_ as any)['subsonic-response']['status'] === 'ok') {
			return JSON.stringify({ status: 'ok', response: 'pong' });
		}
		return JSON.stringify({ status: 'error', response: (_ as any)['subsonic-response']['error']['message'] });
	});
}