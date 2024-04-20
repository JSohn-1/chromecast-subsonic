import fetch from 'node-fetch';
import cryptoRandomString from 'crypto-random-string';
import md5 from 'md5';

import config from '../../config.json';
import { subsonicError, subsonicSong, subsonicPlaylist } from './types';
import { Params } from 'subsonic-api';

import { SubsonicAPI } from 'subsonic-api';
import TermsOfUseFrame from 'node-taglib-sharp/dist/id3v2/frames/termsOfUseFrame';

export interface Credentials {
	username: string;
	password: string;
}

export interface Issue {
	success: boolean;
	error?: string;
}

export class Subsonic {
	static apis: { [uuid: string]: SubsonicAPI } = {};

	username: string;
	password: string;

	constructor(username: string, password: string) {
		this.username = username;
		this.password = password;
	}

	static async login(uuid: string, username: string, password: string): Promise<Issue> {
		if (this.apis[uuid] !== undefined) {
			return { success: false, error: 'already signed in' };
		}

		const api = new SubsonicAPI({
			url: config.subsonic.url,
			type: config.subsonic.type as "navidrome" | "subsonic" | "generic" ?? 'generic', 
		});

		try{
			await api.login({username, password});

			return { success: true }
		}catch (e: unknown) {
			return { success: false, error: e as string ?? 'unknown'};
		}
	}

	static logout(uuid: string): Issue {
		if (this.apis[uuid] === undefined) {
			return { success: false, error: 'not signed in' };
		}

		delete this.apis[uuid];
		return { success: true, error: 'none'};
	}

	static signedIn(uuid: string): boolean {
		return this.apis[uuid] !== undefined;
	}
}
