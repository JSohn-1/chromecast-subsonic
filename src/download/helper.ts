import { SpotifyApi } from '@spotify/web-api-ts-sdk';
import config from '../../config.json';

export function getPlaylistInfo(id: string) {
	const spotify = SpotifyApi.withClientCredentials(
		config.spotdl.clientId,
		config.spotdl.clientSecret
	);

	interface playlistInfo {
		name: string;
		owner: string;
		description: string;
	}

	interface Response {
		status: string;
		response: playlistInfo;
	}

	return new Promise<Response>((resolve, reject) => {
		spotify.playlists.getPlaylist(id)
			.then((res) => {
				resolve({ status: 'ok', response: parsePlaylistInfo(res) });
			}).catch((err) => {
				reject({ status: 'error', response: err });
			});
	});

}

function parsePlaylistInfo(info: { name: string, owner: { display_name: string }, description: string }) {
	return {
		name: info.name,
		owner: info.owner.display_name,
		description: info.description
	};
}