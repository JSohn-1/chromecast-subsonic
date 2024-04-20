import sqlite from 'sqlite'
import { open } from 'sqlite'

export class db {
	static db: sqlite.Database

	static async init() {
		this.db = await open({
			filename: './music.db',
			driver: sqlite.Database
		})
	}

	static async addEntry() {
		
}

}