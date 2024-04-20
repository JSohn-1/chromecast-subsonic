import { File } from 'node-taglib-sharp';
import * as path from 'path';

import { MusicInfo } from './media';
import config from '../../config.json';

import { Subsonic, Issue } from '../subsonic/subsonic';

import { subsonicError } from '../subsonic/types';
import { SubsonicBaseResponse, Child } from 'subsonic-api';
import { subsonicWrapper } from '../routes/subsonic/wrapper';

export async function getMediaInfo(uuid: string, id: string): Promise<Issue | MusicInfo>{
	if (!Subsonic.signedIn(uuid)) {
		return ({ success: false, error: 'not signed in' } as Issue);
	}

	const response = await Subsonic.apis[uuid].customJSON<SubsonicBaseResponse & {song: Child}>('getSong', {id});
	if (response.status !== 'ok'){
		return ({ success: false, error: "error retreiving file"});
	}

	// TODO: grab file location and find artists
	// const filePath = response.song.path;

	// const musicFile = File.createFromPath(path.join(config.spotdl.directory, path.basename(filePath)));
	
	return { 
		title: response.song.title,
		artists: [response.song.artist],
		album: response.song.album,
		year: response.song.year,
		genre: response.song.genre,
		duration: response.song.duration,
		id: id
	} as MusicInfo;
}

