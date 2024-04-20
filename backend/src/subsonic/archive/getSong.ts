// import { generateURL } from './entry';
// import { Credentials } from './subsonic';

// import { subsonicError, subsonicSong } from './types';

// export async function getSong(credentials: Credentials, id: string): Promise<subsonicSong | subsonicError>{
// 	const map = new Map<string, string>();
// 	map.set('id', id);

// 	const response = await fetch(generateURL(credentials, 'getSong', map));
// 	const json = await response.json();

// 	if ( json['subsonic-response'].status === 'ok') {
// 		const data = await response.json();
// 		return data;
// 	}

// 	return {
// 		code: json['subsonic-response'].error.code,
// 		message: json['subsonic-response'].error.message
// 	};
// }
