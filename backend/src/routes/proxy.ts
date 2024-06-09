import express from 'express';
import fetch from 'node-fetch';
import cors from 'cors';
// import httpProxy from 'http-proxy';

import { Subsonic } from '../subsonic/subsonic';
import { Notify } from '../subsonic/notify';
import { Playback } from '../subsonic/playback';
import { Sockets } from './eventHandler';

const middleware = (req: express.Request, res: express.Response, next: express.NextFunction) => {
	// Check if the uuid is authenticated.

	if (!req.query.uuid || typeof req.query.uuid !== 'string') {
		// eslint-disable-next-line no-magic-numbers
		res.status(400).send({ message: 'uuid must be provided as a parameter' });
		return;
	}

	if (typeof req.query.uuid == 'string' && !Subsonic.signedIn(req.query.uuid)) {
		// eslint-disable-next-line no-magic-numbers
		res.status(401).send({ message: 'Unauthorized, you must be signed in' });
		return;
	}

	// Check every item in query to ensure that it is either a string or a number
	for (const key in req.query) {
		const value = req.query[key];
		if (typeof value !== 'string' && typeof value !== 'number') {
			// eslint-disable-next-line no-magic-numbers
			res.status(400).send({ message: 'Invalid query parameter' });
			return;
		}
	}

	next();
};

const proxy = (res: express.Response, target: string) => {
	fetch(target).then(async (response) => {
		response.headers.forEach((value, name) => {
			res.setHeader(name, value);
		});

		response.body?.pipe(res);

		response.body?.on('end', () => {
			res.end();
		});
	});
};

// Requests must contain the following paramters:
// UUID: A unique identifier for the user.
// Method: The method to be called.
// Args: The arguments for the method.

export const subsonicRoutes = (app: express.Application) => {
	app.use(cors());

	app.post('/subsonic/login', async (req, res) => {
		if (!req.query.uuid || !req.query.username || !req.query.password) {
			// eslint-disable-next-line no-magic-numbers
			res.status(400).send({ message: 'username and password must be provided' });
			return;
		}

		const response = await Subsonic.login(req.query.uuid as string, req.query.username as string, req.query.password as string, req.query.uuid as string);

		if (response.success) {
			Notify.newUser(req.query.username as string, req.query.uuid as string, Sockets.sockets[req.query.uuid as string]);

			Playback.savePlayback(Subsonic.apis[req.query.uuid as string], Sockets.sockets[req.query.uuid as string]);
		}

		res.status(response.success ? 
			// eslint-disable-next-line no-magic-numbers
			200 : 401
		).send(response);
	});

	app.use(middleware);

	app.get('/subsonic/ping', (req, res) => {
		if (Subsonic.signedIn(req.query.uuid as string) === false) {
			// eslint-disable-next-line no-magic-numbers
			res.status(403).send({ message: 'Unauthorized, you must be signed in' });
			return;
		}
		res.send({ message: 'pong' });
	});

	app.get('/subsonic/stream', (req, res) => {
		if (!req.query.id) {
			// eslint-disable-next-line no-magic-numbers
			res.status(400).send({ message: 'id must be provided as a parameter' });
			return;
		}

		const SubsonicClient = Subsonic.apis[req.query.uuid as string];
		const streamURL = SubsonicClient.stream({ id: req.query.id as string }).url;	

		proxy(res, streamURL);
	});

	app.get('/subsonic/cover', (req, res) => {
		if (!req.query.id) {
			// eslint-disable-next-line no-magic-numbers
			res.status(400).send({ message: 'id must be provided as a parameter' });
			return;
		}
		
		const SubsonicClient = Subsonic.apis[req.query.uuid as string];
		const coverURL = SubsonicClient.albumCover({ id: req.query.id as string }).url;

		proxy(res, coverURL);
	});

	app.get('/subsonic', (req, res) => {
		const SubsonicClient = Subsonic.apis[req.query.uuid as string];
		const method = req.query.method as string;
		const args = { ...req.query as { [key: string]: string | number }};
		delete args.uuid;
		delete args.method;

		const url = SubsonicClient._generateURL(method, { ...args });

		fetch(url).then(async (response) => {
			const data = await response.json();
			res.send(data);
		});
	});
};

export const queueRoutes = (app: express.Application) => {
	app.get('/queue', (req, res) => {
		const username = Subsonic.apis[req.query.uuid as string].username;
		const queue = Playback.users[username].playback;

		res.send(queue);
	});
};
