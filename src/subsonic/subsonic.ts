import { ping } from './ping';
import { getPlaylists } from './getPlaylists';

export class Subsonic {
    static ping = ping;
    static getPlaylists = getPlaylists;
}
