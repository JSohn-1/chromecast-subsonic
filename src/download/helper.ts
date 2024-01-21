import { SpotifyApi } from "@spotify/web-api-ts-sdk";
import config from '../../config.json';

export function getPlaylistInfo(id: string){
    const spotify = SpotifyApi.withClientCredentials(
        config.spotdl.clientId,
        config.spotdl.clientSecret
    );

    interface Response {
        status: string;
        response: any;
    }

    return new Promise<Response>(async (resolve, reject) => {
        console.log(id)
        await spotify.playlists.getPlaylist(id).then((res) => {
            resolve({status: 'ok', response: parsePlaylistInfo(res)});
        }).catch((err) => {
            reject({status: "error", response: err});
        });
    });

}

function parsePlaylistInfo(info: any){
    return {
        name: info.name,
        owner: info.owner.display_name,
        description: info.description
    }
}