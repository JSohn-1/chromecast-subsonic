import { Socket } from "socket.io";
import { Subsonic } from "../../subsonic/subsonic";

import { utils } from "./utils";
import { playlists } from "./playlists";
import { media } from "./media";

export const subsonicWrapper = (socket: Socket, uuid: string) => {
	utils(socket);
	playlists(socket);
	media(socket);
}