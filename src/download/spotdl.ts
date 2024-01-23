import { spawn } from 'node:child_process';

import { getPlaylistInfo } from './helper';
import config from '../../config.json';

export function download(url: string) {
	const name = getPlaylistInfo(url).then((_: string) => {
		return JSON.parse(_).response.name;
	}).then((_: string) => {
		const command = spawn('./download.sh', [config.spotdl.server, config.spotdl.username, config.spotdl.password, _, config.spotdl.directory, url]);
		command.stdout.on('data', (chunk: any) => {
			console.log(chunk.toString()); // data from the standard output is here as buffers
			// data from standard output is here as buffers
		});

		// since these are streams, you can pipe them elsewhere
		//   command.stderr.pipe(dest);

		command.on('close', (code: any) => {
			console.log(`child process exited with code ${code}`);
		});
	});


	// use child.stdout.setEncoding('utf8'); // if you want text chunks


}

