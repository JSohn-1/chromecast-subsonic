// Perform initial setup when a user connects to the socket.io server

import { v4 as uuidv4 } from 'uuid';
import { Socket } from 'socket.io';
import { Chromecast } from '../chromecast/chromecast';

import { subsonicWrapper } from './subsonic/wrapper';
import { chromecastRoutes } from './chromecast';

export const eventHandler = (socket: Socket) => {
  const uuid = uuidv4();
  console.log('a user connected: ' + uuid);

  socket.on('disconnect', () => {
	Chromecast.clearListener(uuid);
	console.log('a user disconnected');
  });

  subsonicWrapper(socket, uuid);
  chromecastRoutes(socket, uuid);
};