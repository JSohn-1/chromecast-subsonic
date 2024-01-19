// Create restful api server which just returns pong to a ping request

import { Subsonic } from './subsonic/subsonic';

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

app.listen(port, () => {
  console.log(`Server listening at http://localhost:${port}`);
});
