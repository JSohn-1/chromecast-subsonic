import { SpotifyApi } from "@spotify/web-api-ts-sdk";
import config from '../../config.json';

export function verifyURL(url: string){
    
}

export function getPlaylistInfo(url: string){
    

    const spotify = SpotifyApi.withClientCredentials(
        config.spotdl.clientId,
        config.spotdl.clientSecret
    );

    spotify.getPlaylist(url).then((res) => {
        console.log(res.body);
    })
}