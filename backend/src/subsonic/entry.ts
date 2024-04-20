// import cryptoRandomString from 'crypto-random-string';
// import fetch from 'node-fetch';
// import md5 from 'md5';

// // import the config file
// import config from '../../config.json';

// import { Credentials } from './subsonic';

// static generateURL(credentials: Credentials, method: string, data?: Params): string {
// 	const salt: string = cryptoRandomString({ length: 10 });
// 	const params: Map<string, string> = new Map();
// 	params.set('u', credentials.username);
// 	params.set('t', md5(credentials.password + salt));
// 	params.set('s', salt);
// 	params.set('v', '1.16.1');
// 	params.set('c', 'subsonic-restful-api');
// 	params.set('f', 'json');
	
// 	if (data) {
// 		for (const [key, value] of Object.entries(data)) {
// 			params.set(key, value as string);
// 		}
// 	}
	
// 	let url: string = `${config.subsonic.url}/rest/${method}?`;
// 	params.forEach((value, key) => {
// 		url += key + '=' + value + '&';
// 	});
// 	url = url.slice(0, -1);
	
// 	return url;
// }

// async getSong(args: { id: string }) {
// 	return this._requestHandler<subsonicError & {song: subsonicSong}>('getSong', args);
// }

// async getPlaylist(args: { id: string }) {
// 	return this._requestHandler<subsonicError & { playlist: subsonicPlaylist}>('getPlaylist', args);
// }

// async _requestHandler<T>(method: string, data?: Params): Promise<T> {
// 	const url: string = Subsonic.generateURL({username: this.username, password: this.password}, method, data);

// 	const response = await fetch(url);
// 	const json = await response.json();

// 	return json['subsonic-response'];
// }

// 	const response = await fetch(Subsonic.generateURL({ username, password }, 'ping'));
		
// try {
// 	const data = await response.json();
// 	if (data['subsonic-response'].status === 'ok') {
// 		this.apis[uuid] = new Subsonic(username, password);
// 		return { success: true, error: 'none' };
// 	} else {
// 		return { success: false, error: data.error?.message };
// 	}
// } catch (error: unknown) {
// 	return { success: false, error: (error as Error ?? Error('unknown issue')).message };
// }
