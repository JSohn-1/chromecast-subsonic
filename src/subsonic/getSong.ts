import { _requestHandler } from './entry';

export function getSong(id: string) {
	const map = new Map<string, string>();
	map.set('id', id);

	return _requestHandler('getSong', map).then((_: JSON) => {
		if ((_ as any)['subsonic-response']['status'] === 'ok') {
			return JSON.stringify({ status: 'ok', response: (_ as any)['subsonic-response']['song'] });
		}
		return JSON.stringify({ status: 'error', response: (_ as any)['subsonic-response']['error']['message'] });
	});
}