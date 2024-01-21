const ChromecastAPI = require('chromecast-api')

import { getChromecasts } from './utilChromecast';

export class Chromecast {
    static client = new ChromecastAPI();

    static init(){
        return new Promise<void>((resolve, reject) => {
            this.client.on('device', (device: any) => {
                resolve();
            });
            this.client.on('error', (error: any) => {
                reject(error);
            });

        });
    }

    static getChromecasts(){return getChromecasts(this.client)};
}