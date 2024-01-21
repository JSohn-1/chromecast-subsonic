// Create restful api server which just returns pong to a ping request

import { Subsonic } from './subsonic/subsonic';
import { getPlaylistInfo } from './download/helper';
import { getChromecasts } from './chromecast/utilChromecast';
import { Chromecast } from './chromecast/chromecast';

Chromecast.init();

const express = require('express');
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

Chromecast.init()
.then(() => {
    app.listen(port, () => {
    console.log(`Server listening at http://localhost:${port}`);
  });});


