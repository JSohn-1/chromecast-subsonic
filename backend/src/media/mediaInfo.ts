import { File } from 'node-taglib-sharp';
import * as path from 'path';

import { MusicInfo } from './media';
import config from '../../config.json';

import { Subsonic, Issue } from '../subsonic/subsonic';

import { subsonicError } from '../subsonic/types';

export async function getMediaInfo(uuid: string, id: string): Promise<Issue | MusicInfo>{
	if (!Subsonic.signedIn(uuid)) {
		return ({ success: false, error: 'not signed in' } as Issue);
	}
	const response = await Subsonic.apis[uuid].getSong({id});
	if (response.code !== undefined){
		return ({ success: false, error: (response as subsonicError).message } as Issue);
	}

	const filePath = response.song.path;

	const musicFile = File.createFromPath(path.join(config.spotdl.directory, path.basename(filePath)));
	
	return { 
		title: musicFile.tag.title,
		artists: musicFile.tag.albumArtists,
		album: musicFile.tag.album,
		year: musicFile.tag.year,
		genre: musicFile.tag.genres,
		duration: musicFile.properties.durationMilliseconds,
		id: id
	} as MusicInfo;
}

