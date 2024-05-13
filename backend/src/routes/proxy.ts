import express from 'express';
import fetch from 'node-fetch';
// import httpProxy from 'http-proxy';

import { Subsonic } from '../subsonic/subsonic';

const middleware = (req: express.Request, res: express.Response, next: express.NextFunction) => {
	// Check if the uuid is authenticated.

	if (req.query.uuid && typeof req.query.uuid == 'string' && !Subsonic.signedIn(req.query.uuid)) {
		// eslint-disable-next-line no-magic-numbers
		res.status(401).send({ message: 'Unauthorized, uuid must be provided as a parameter and you must be signed in' });
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
	});
};

// Requests must contain the following paramters:
// UUID: A unique identifier for the user.
// Method: The method to be called.
// Args: The arguments for the method.

export const subsonicRoutes = (app: express.Application) => {
	app.use(middleware);

	app.get('/subsonic/ping', (req, res) => {
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
};
