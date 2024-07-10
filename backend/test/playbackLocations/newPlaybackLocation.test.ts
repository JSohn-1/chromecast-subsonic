import {describe, expect, test} from '@jest/globals';
import { createServer } from 'node:http';
import { type AddressInfo } from 'node:net';
import { io as ioc, type Socket as ClientSocket } from 'socket.io-client';
import { Server, type Socket as ServerSocket } from 'socket.io';
import express from 'express';
import { eventHandler } from '../../src/routes/eventHandler';
import { playbackRoutes, queueRoutes, subsonicRoutes } from '../../src/routes/proxy';
import { Playback } from '../../src/subsonic/playback';
import { Subsonic } from '../../src/subsonic/subsonic';
import { Notify } from '../../src/subsonic/notify';

describe('new playback location support', () => {
	let io: Server;
	let clientSocketOne: ClientSocket;
	let clientSocketTwo: ClientSocket;
	let serverSockets: ServerSocket[] = [];

	beforeAll((done) => {
		Notify.users = {};
		Playback.users = {};

		serverSockets = [];

		const app = express();

		const httpServer = createServer(app);
		io = new Server(httpServer);

		subsonicRoutes(app);
		queueRoutes(app);
		playbackRoutes(app);

		httpServer.listen(() => {
			const port = (httpServer.address() as AddressInfo).port;

			clientSocketOne = ioc(`http://localhost:${port}`);
			clientSocketTwo = ioc(`http://localhost:${port}`);

			// Setup connection event handler for both sockets
			const connectPromiseOne = new Promise<void>((resolve) => clientSocketOne.on('connect', resolve));
			const connectPromiseTwo = new Promise<void>((resolve) => clientSocketTwo.on('connect', resolve));
	
			Promise.all([connectPromiseOne, connectPromiseTwo]).then(() => {
				done();
			});

			io.on('connection', (socket) => {
				eventHandler(socket);
				serverSockets.push(socket);
			});
		});
	});

	beforeEach(() => {
		Notify.users = {};
		Playback.users = {};
	});

	afterAll(() => {
		io.close();
		clientSocketOne.disconnect();
		clientSocketTwo.disconnect();
	});

	test('should notify when new location connects', (done) => {
		const subsonicClient = new Subsonic('test', 'test');

		Notify.newUser('test', serverSockets[0].id, serverSockets[0]);
		Playback.savePlayback(subsonicClient, 'first', serverSockets[0]);

		clientSocketOne.on('newLocation', (data) => {
			expect(data).toEqual([clientSocketTwo.id, 'second']);
			done();
		});

		Notify.newUser('test', serverSockets[1].id, serverSockets[1]);
		Playback.savePlayback(subsonicClient, 'second', serverSockets[1]);
	});

	test('should notify when location disconnects', (done) => {
		const id = serverSockets[1].id;
		const subsonicClient = new Subsonic('test', 'test');

		Notify.newUser('test', serverSockets[0].id, serverSockets[0]);
		Playback.savePlayback(subsonicClient, 'first', serverSockets[0]);

		clientSocketOne.on('removeLocation', (data) => {
			expect(data[0]).toEqual(id);
			done();
		});

		clientSocketOne.on('newLocation', (data) => {
			expect(data).toEqual([clientSocketTwo.id, 'second']);
			clientSocketTwo.disconnect();
		});

		Notify.newUser('test', serverSockets[1].id, serverSockets[1]);
		Subsonic.apis[serverSockets[1].id] = subsonicClient;
		Playback.savePlayback(subsonicClient, 'second', serverSockets[1]);
	});
});
