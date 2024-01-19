import {_requestHandler} from './entry';

export function ping(): string{
    _requestHandler('ping', new Map()).then((_: JSON) => {
        if ((_ as any)['subsonic-response']['status'] === 'ok'){
            return 'pong';
        }
        return 'error';
    })
    .catch((err: any) => {
        console.error(err)
        return err;
    });
    return 'route';
    // Use the request handler to make a ping request and return pong if the request is successful
    
    
}