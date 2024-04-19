export interface subsonicSong {
  id: string;
  title: string;
  path: string;
  duration: number;
  coverArt: string;
}

export interface subsonicPlaylist {
	id: string;
	name: string;
	coverArt: string;
	entry: subsonicSong[];
}	

export interface subsonicResponse {
	status: string;
}

export interface subsonicError {
	code: number;
	message: string;
}
