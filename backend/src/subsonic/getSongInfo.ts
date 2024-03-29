import { generateURL } from './entry';
import { getSong } from './getSong';

export function getSongInfo(id: string) {
	return getSong(id).then((_) => {
		const __ = JSON.parse(_);
		if (__['status'] === 'ok') {
			const data = __['response'];
			const songInfo = {
				id: data.id,
				title: data.title,
				artist: data.artist,
				coverURL: generateURL('getCoverArt', new Map([['id', id]])),
				duration: data.duration,
			};
			return { status: 'ok', response: songInfo };
		}
		return { status: 'error', response: __['response'] };
	}).catch((err: string) => {
		return { status: 'error', response: err };
	});
}
