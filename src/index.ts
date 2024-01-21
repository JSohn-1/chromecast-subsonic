// Create restful api server which just returns pong to a ping request

import { Subsonic } from './subsonic/subsonic';
import { getPlaylistInfo } from './download/helper';
import { getChromecasts } from './chromecast/utilChromecast';
import { Chromecast } from './chromecast/chromecast';

Chromecast.init();

import express from 'express';
const app = express();
const port = 3000;

app.get('/ping', (req: string, res: any) => {
	Subsonic.ping().then((_: string) => {
		res.send(_);
	});
});

app.get('/getPlaylists', (req: string, res: any) => {
	Subsonic.getPlaylists().then((_: string) => {
		res.send(_);
	});
});

app.get('/getPlaylist', (req: any, res: any) => {
	Subsonic.getPlaylist(req.query.id).then((_: string) => {
		res.send(_);
	});
});

app.get('/playlistInfo', (req: any, res: any) => {
	console.log('init');
	getPlaylistInfo(req.query.id).then((_: any) => {
		res.send(_);
	});
});

app.get('/getChromecasts', (req: any, res: any) => {
	res.send(Chromecast.getChromecasts());
});

app.post('/play', (req: any, res: any) => {
	Chromecast.play(req.query.chromecastName, req.query.songId).then((_: any) => {
		res.send(_);
	});
});

app.post('/pause', (req: any, res: any) => {
	Chromecast.pause(req.query.chromecastName).then((_: any) => {
		res.send(_);
	});
});

app.post('/resume', (req: any, res: any) => {
	Chromecast.resume(req.query.chromecastName).then((_: any) => {
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


