// Create restful api server which just returns pong to a ping request

import { Subsonic } from './subsonic/subsonic';
import { getPlaylistInfo } from './download/helper';
import { Chromecast } from './chromecast/chromecast';

import express from 'express';

const app = express();
const port = 3000;

app.get('/ping', (req, res) => {
	Subsonic.ping().then((_: string) => {
		res.send(_);
	});
});

app.get('/getPlaylists', (req, res) => {
	Subsonic.getPlaylists().then((_: string) => {
		res.send(_);
	});
});

app.get('/getPlaylist', (req, res) => {
	const id = req.query.id ? req.query.id.toString() : '';

	if (!id) {
		res.send({ status: 'error', response: 'no id provided' });
		return;
	}

	Subsonic.getPlaylist(id).then((_: string) => {
		res.send(_);
	});
});

app.get('/playlistInfo', (req, res) => {
	const id = req.query.id ? req.query.id.toString() : '';

	if (!id) {
		res.send({ status: 'error', response: 'no id provided' });
		return;
	}

	getPlaylistInfo(id).then((_) => {
		res.send(_);
	});
});

app.get('/getChromecasts', (req, res) => {
	res.send(Chromecast.getChromecasts());
});

app.post('/play', (req, res) => {
	const songId = req.query.id ? req.query.id.toString() : '';
	const chromecastName = req.query.chromecastName ? req.query.chromecastName.toString() : '';

	if (!songId || !chromecastName) {
		res.send({ status: 'error', response: 'incorrect parameters' });
		return;
	}

	Chromecast.play(chromecastName, songId).then((_) => {
		res.send(_);
	});
});

app.post('/pause', (req, res) => {
	const chromecastName = req.query.chromecastName ? req.query.chromecastName.toString() : '';

	if (!chromecastName) {
		res.send({ status: 'error', response: 'incorrect parameters' });
		return;
	}
	Chromecast.pause(chromecastName).then((_) => {
		res.send(_);
	});
});

app.post('/resume', (req, res) => {
	const chromecastName = req.query.chromecastName ? req.query.chromecastName.toString() : '';

	if (!chromecastName) {
		res.send({ status: 'error', response: 'incorrect parameters' });
		return;
	}
	Chromecast.resume(chromecastName).then((_) => {
		res.send(_);
	});
});

console.log('Discovering Chromecasts...');
Chromecast.init()
	.then(() => {
		console.log('Chromecasts discovered.');
		app.listen(port, () => {
			console.log(`Server listening at http://localhost:${port}`);
		});
	});


