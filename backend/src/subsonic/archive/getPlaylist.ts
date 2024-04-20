// import { generateURL } from './entry';
// import { Credentials } from './subsonic';

// import { subsonicError, subsonicSong } from './types';

// export async function getSong(credentials: Credentials, id: string): Promise<subsonicSong | subsonicError>{
// 	const map = new Map<string, string>();
// 	map.set('id', id);

// 	const response = await fetch(generateURL(credentials, 'getPlaylist', map));
// 	const json = await response.json();

// 	return json;
// }
