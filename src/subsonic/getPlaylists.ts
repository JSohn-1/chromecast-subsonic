import {_requestHandler} from './entry';

export function getPlaylists(){
    return _requestHandler('getPlaylists', new Map()).then((_: JSON) => {
        if ((_ as any)['subsonic-response']['status'] === 'ok'){
            
            return JSON.stringify({status: 'ok', response: (_ as any)['subsonic-response']['playlists']['playlist']});
        }
        return JSON.stringify({status: 'error', response: (_ as any)['subsonic-response']['error']['message']});
    })
}