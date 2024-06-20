import { EventEmitter } from 'events';

export class Notify {
	static users: { [username: string]: {uuid: string, socket: EventEmitter}[] } = {};

	static newUser(username: string, uuid: string, socket: EventEmitter) {
		if (this.users[username] === undefined) {
			this.users[username] = [{ uuid, socket }];
		} else {
			this.users[username].push({ uuid, socket });
		}

		socket.on('disconnect', () => {
			this.users[username] = this.users[username].filter((user) => user.uuid !== uuid);
		});
	}

	static removeUser(uuid: string) {
		for (const user in this.users) {
			this.users[user] = this.users[user].filter((user) => user.uuid !== uuid);
		}
	}

	static notifyUsers(user: string, event: string, message: object, exclude?: string) {
		// console.log(event);
		for (const socket of this.users[user]) {
			if (exclude != undefined && socket.uuid === exclude) {
				continue;
			}

			socket.socket.emit(event, message);
		}
	}
}
