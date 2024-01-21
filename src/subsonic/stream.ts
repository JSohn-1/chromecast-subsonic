import { generateURL } from './entry';
import { getSong } from './getSong';

export function stream(id: string){
    const songURL = generateURL('stream', new Map([['id', id]]));
    const coverURL = generateURL('getCoverArt', new Map([['id', id]]));

    return new Promise<{ songURL: string, coverURL: string, title: string }>((resolve, reject) => {
        getSong(id).then((response: any) => {
            resolve({ songURL, coverURL, title: response.title });
        }).catch((err: any) => {
            reject(err);
        });
    });

}