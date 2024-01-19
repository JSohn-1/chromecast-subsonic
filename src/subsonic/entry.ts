const https = require('https');
const cryptoRandomString = require('crypto-random-string');
// import cryptoRandomString from 'crypto-random-string';

const md5 = require('md5');

import { constants } from '../helper/constants';

    export function _requestHandler(method: string, data: Map<any, any>){
        const salt: string = cryptoRandomString({length: 10});
        const params: Map<any, any> = new Map();
        params.set('u', constants.username);
        params.set('t', md5(constants.password + salt));
        params.set('s', salt);
        params.set('v', '1.16.1');
        params.set('c', 'subsonic-restful-api');
        params.set('f', 'json');

        data.forEach((value, key) => {
            params.set(key, value);
        });
        
        let url: string = `${constants.url}/rest/${method}?`;
        params.forEach((value, key) => {
            url += key + '=' + value + '&';
        });
        url = url.slice(0, -1);

        return new Promise<JSON>((resolve, reject) => {
            https.get(url, (res: any) => {
                let data = '';
                res.on('data', (chunk: any) => {
                    data += chunk;
                });
                res.on('end', () => {
                    resolve(JSON.parse(data));
                });
            }).on('error', (err: any) => {
                reject(err);
            });
        });
    }
