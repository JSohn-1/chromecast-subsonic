import { Socket } from 'socket.io';

export enum playbackState {
	PLAYING = 'PLAYING',
	PAUSED = 'PAUSED',
	STOPPED = 'STOPPED',
}

export class Local {
	state: playbackState;
	socket: Socket;

	constructor(socket: Socket){
		this.state = playbackState.STOPPED;
		this.socket = socket;

		socket.on('getState', () => {
			socket.emit('changeState', this.state);
		});
	}

	play(id: string) {
		this.changeState(playbackState.PLAYING);
		this.socket.emit('play', id);
	}

	resume() {
		this.changeState(playbackState.PLAYING);
		this.socket.emit('resume');
	}

	pause() {
		this.changeState(playbackState.PAUSED);
		this.socket.emit('pause');
	}

	changeState(state: playbackState) {
		this.state = state;
		this.socket.emit('changeState', this.state);
	}

	skip() {
		this.socket.emit('skip');
	}

	previous() {
		this.socket.emit('previous');
	}

	toJSON() {
		return {
			uuid: this.socket.id,
			state: this.state,
		};
	}
}
