import {_requestHandler} from './entry';

export function getPlaylist(id: string){
    let map = new Map<string, string>();
    map.set('id', id);

    return _requestHandler('getPlaylist', map).then((_: JSON) => {
        if ((_ as any)['subsonic-response']['status'] === 'ok'){
            return JSON.stringify({status: 'ok', response: (_ as any)['subsonic-response']['playlist']});
        }
        return JSON.stringify({status: 'error', response: (_ as any)['subsonic-response']['error']['message']});
    })
}