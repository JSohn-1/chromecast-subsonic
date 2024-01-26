import { spawn } from 'node:child_process';
import eventEmitter from 'events';

import { getPlaylistInfo } from './helper';
import config from '../../config.json';

export function download(url: string, socket: eventEmitter) {
	getPlaylistInfo(url).then((_: string) => {
		const name = JSON.parse(_).response.name;

		const command = spawn('./download.sh', [config.spotdl.server, config.spotdl.username, config.spotdl.password, name, config.spotdl.directory, url]);
		command.stdout.on('data', (chunk) => {
			socket.emit('spotdl', chunk.toString());
			console.log(chunk.toString()); // data from the standard output is here as buffers
			// data from standard output is here as buffers
		});

		// since these are streams, you can pipe them elsewhere
		//   command.stderr.pipe(dest);

		command.on('close', (code) => {
			socket.emit('spotdl', `child process exited with code ${code}`);
			console.log(`child process exited with code ${code}`);
		});
	});

	// use child.stdout.setEncoding('utf8'); // if you want text chunks

}

