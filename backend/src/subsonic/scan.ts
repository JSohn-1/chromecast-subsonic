import { _requestHandler } from './entry';

export function startScan() {
	const map = new Map<string, string>();

	return _requestHandler('startScan', map).then((_) => {
		const __ = JSON.parse(_);
		if (__['subsonic-response'].status === 'ok') {
			return JSON.stringify({ status: 'ok', response: __['subsonic-response']['scanStatus'] });
		}
		return JSON.stringify({ status: 'error', response: __['subsonic-response']['error']['message'] });
	}).catch((err: string) => {
		return JSON.stringify({ status: 'error', response: err });
	});
}

export function getScanStatus() {
	const map = new Map<string, string>();

	return _requestHandler('getScanStatus', map).then((_) => {
		const __ = JSON.parse(_);
		if (__['subsonic-response'].status === 'ok') {
			return JSON.stringify({ status: 'ok', response: __['subsonic-response']['scanStatus'] });
		}
		return JSON.stringify({ status: 'error', response: __['subsonic-response']['error']['message'] });
	}).catch((err: string) => {
		return JSON.stringify({ status: 'error', response: err });
	});
}