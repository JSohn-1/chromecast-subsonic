import fetch from 'node-fetch';
import cryptoRandomString from 'crypto-random-string';
import md5 from 'md5';

import config from '../../config.json';
import { subsonicError, subsonicSong } from './types';
import { Params } from 'subsonic-api';

export interface Credentials {
	username: string;
	password: string;
}

export interface Issue {
	success: boolean;
	error: string;
}

export class Subsonic {
	static apis: { [uuid: string]: Subsonic } = {};

	username: string;
	password: string;

	constructor(username: string, password: string) {
		this.username = username;
		this.password = password;
	}

	static generateURL(credentials: Credentials, method: string, data?: Params): string {
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

	async getSong(args: { id: string }) {
		return this._requestHandler<subsonicError & {song: subsonicSong}>('getSong', args);
	}

	async _requestHandler<T>(method: string, data?: Params): Promise<T> {
		const url: string = Subsonic.generateURL({username: this.username, password: this.password}, method, data);

		const response = await fetch(url);
		const json = await response.json();

		return json['subsonic-response'];
	}

	static async login(uuid: string, username: string, password: string): Promise<Issue> {
		if (this.apis[uuid] !== undefined) {
			return { success: false, error: 'already signed in' };
		}

		const response = await fetch(Subsonic.generateURL({ username, password }, 'ping'));
		
		try {
			const data = await response.json();
			if (data['subsonic-response'].status === 'ok') {
				this.apis[uuid] = new Subsonic(username, password);
				return { success: true, error: 'none' };
			} else {
				return { success: false, error: data.error?.message };
			}
		} catch (error: unknown) {
			return { success: false, error: (error as Error ?? Error('unknown issue')).message };
		}
	}

	static logout(uuid: string): Issue {
		if (this.apis[uuid] === undefined) {
			return { success: false, error: 'not signed in' };
		}

		delete this.apis[uuid];
		return { success: true, error: 'none'};
	}

	// getSong(id: string){ return getSong({username: this.username, password: this.password}, id);}

	static signedIn(uuid: string): boolean {
		return this.apis[uuid] !== undefined;
	}
}
