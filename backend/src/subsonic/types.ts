export interface subsonicSong {
  id: string;
  title: string;
  album: string;
  artist: string;
  genre: string;
  path: string;
  duration: number;
  coverArt: string;
}

export interface subsonicPlaylist {
	id: string;
	name: string;
	entry: subsonicSong[];
}	

export interface SubsonicPlaylistInfo {
	id: string;
	name: string;
}

export interface subsonicResponse {
	status: string;
}

export interface subsonicError {
	code: number;
	message: string;
}
