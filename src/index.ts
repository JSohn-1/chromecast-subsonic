// Create restful api server which just returns pong to a ping request

import { Subsonic } from './subsonic/subsonic';

const express = require('express');
const app = express();
const port = 3000;

app.get('/ping', (req: string, res: any) => {
//   console.log(Subsonic.ping());
  
  res.send(Subsonic.ping());
});

app.listen(port, () => {
  console.log(`Server listening at http://localhost:${port}`);
});
