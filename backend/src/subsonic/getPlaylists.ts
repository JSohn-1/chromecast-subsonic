// import { _requestHandler } from './entry';
// import { Credentials } from './subsonic';

// export function getPlaylists(credentials: Credentials) {
// 	return _requestHandler(credentials, 'getPlaylists', new Map()).then((_) => {
// 		const __ = JSON.parse(_);
// 		if (__['subsonic-response']['status'] === 'ok') {
// 			return { status: 'ok', response: __['subsonic-response']['playlists']['playlist'] };
// 		}
// 		return { status: 'error', response: __['subsonic-response']['error']['message'] };
// 	}).catch((err: string) => {
// 		return { status: 'error', response: err };
// 	});
// }
