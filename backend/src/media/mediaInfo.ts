// import { File } from 'node-taglib-sharp';
// import * as path from 'path';

// import { baseResponse, MusicInfo } from './media';
// import config from '../../config.json';

import { Subsonic } from '../subsonic/subsonic';

export async function getMediaInfo(uuid: string, id: string) {
	if (!Subsonic.signedIn(uuid)) {
		return ({success: false, message: 'not signed in'});
	}

	const response = await Subsonic.apis[uuid].getSong({ id });
	if (response.error){
		return ({ success: false, message: response.error.message});
	}

	// TODO: grab file location and find artists
	// const filePath = response.song.path;

	// const musicFile = File.createFromPath(path.join(config.spotdl.directory, path.basename(filePath)));
	
	const song = response.song!;

	return {
		success: true,
		song: {
			title: song.title,
			artists: [song.artist],
			album: song.album,
			// year: response.song.year,
			genre: song.genre,
			duration: song.duration,
			id: id
		}
	};
}

