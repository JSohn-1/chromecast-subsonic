import fetch from 'node-fetch';
import cryptoRandomString from 'crypto-random-string';
import md5 from 'md5';

import config from '../../config.json';
import { subsonicError, subsonicResponse, subsonicSong, subsonicPlaylist } from './types';
import { Params } from 'subsonic-api';
import { Playback } from './playback';

// import { baseResponse } from '../media/media';

export interface Credentials {
	username: string;
	password: string;
}

export interface Issue {
	message: string;
}

export interface link {
	url: string;
}

export class Subsonic {
	static apis: { [uuid: string]: Subsonic } = {};

	username: string;
	password: string;

	constructor(username: string, password: string) {
		this.username = username;
		this.password = password;
	}

	static async login(uuid: string, username: string, password: string) {
		if (this.apis[uuid] !== undefined) {
			return { success: false, message: 'already signed in' };
		}
		
		const response = await fetch(Subsonic._generateURL({ username, password }, 'ping'));

		try {
			const data = await response.json();
			if (data['subsonic-response'].status === 'ok') {
				const api = new Subsonic(username, password);
				this.apis[uuid] = api;
				Playback.savePlayback(api);

				return { success: true };
			} else {
				return { success: false, message: data.error?.message };
			}
		} catch (error: unknown) {
			return { success: false, message: (error as Error ?? Error('unknown issue')).message };
		}

	}

	static logout(uuid: string){
		if (this.apis[uuid] === undefined) {
			return { success: false, message: 'not signed in' };
		}

		delete this.apis[uuid];
		return { success: true };
	}

	static signedIn(uuid: string): boolean {
		return this.apis[uuid] !== undefined;
	}

	// generic subsonic methods
	async getSong(args: { id: string }) {
		return this._requestHandler<subsonicResponse & {song?: subsonicSong; error?: subsonicError}>('getSong', args);
	}

	async getPlaylist(args: { id: string }) {
		return this._requestHandler<subsonicResponse & { playlist: subsonicPlaylist}>('getPlaylist', args);
	}

	async getPlaylists() {
		return this._requestHandler<subsonicResponse & { playlists: subsonicPlaylist[]}>('getPlaylists');
	}

	// Media retrieval
	stream(args: { id: string }) {
		return { url: Subsonic._generateURL({ username: this.username, password: this.password }, 'stream', args) };
	}

	albumCover(args: { id: string }) {
		return { url: Subsonic._generateURL({ username: this.username, password: this.password }, 'getCoverArt', args) };
	}

	static _generateURL(credentials: Credentials, method: string, data?: Params): string {
		const salt: string = cryptoRandomString({ length: 10 });
		const params: Map<string, string> = new Map();
		params.set('u', credentials.username);
		params.set('t', md5(credentials.password + salt));
		params.set('s', salt);
		params.set('v', '1.16.1');
		params.set('c', 'subsonic-restful-api');
		params.set('f', 'json');
		
		if (data) {
			for (const [key, value] of Object.entries(data)) {
				params.set(key, value as string);
			}
		}
		
		let url: string = `${config.subsonic.url}/rest/${method}?`;
		params.forEach((value, key) => {
			url += key + '=' + value + '&';
		});
		url = url.slice(0, -1);
		
		return url;
	}

	async _requestHandler<T>(method: string, data?: Params): Promise<T> {
		const url: string = Subsonic._generateURL({username: this.username, password: this.password}, method, data);

		const response = await fetch(url);
		const json = await response.json();

		return json['subsonic-response'];
	}
}
