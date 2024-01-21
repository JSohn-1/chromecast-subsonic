const https = require('https');
const cryptoRandomString = require('crypto-random-string');
// import cryptoRandomString from 'crypto-random-string';

const md5 = require('md5');

// import the config file
import config from '../../config.json';

    export function _requestHandler(method: string, data: Map<any, any>){
        const salt: string = cryptoRandomString({length: 10});
        const params: Map<any, any> = new Map();
        params.set('u', config.subsonic.username);
        params.set('t', md5(config.subsonic.password + salt));
        params.set('s', salt);
        params.set('v', '1.16.1');
        params.set('c', 'subsonic-restful-api');
        params.set('f', 'json');

        data.forEach((value, key) => {
            params.set(key, value);
        });
        
        let url: string = `${config.subsonic.url}/rest/${method}?`;
        params.forEach((value, key) => {
            url += key + '=' + value + '&';
        });
        url = url.slice(0, -1);

        return new Promise<JSON>((resolve, reject) => {
            fetch(url)
            .then(async (res: any) => {  
                resolve(await res.json());
            })
            .catch((err: any) => {
                reject(err);
            });
        });
    }
