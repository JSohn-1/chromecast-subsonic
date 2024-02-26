import { Socket } from 'socket.io';

import { utils } from './utils';
import { playlists } from './playlists';
import { media } from './media';

export const subsonicWrapper = (socket: Socket) => {
	utils(socket);
	playlists(socket);
	media(socket);
};
