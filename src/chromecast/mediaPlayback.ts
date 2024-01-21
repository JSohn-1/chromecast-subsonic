import { stream } from '../subsonic/stream';

export function play(client: any, chromecastName: string, songId: string) {
    const device = client.devices.find((device: any) => device.friendlyName === chromecastName);

    return new Promise<JSON>((resolve, reject) => {stream(songId)
    .then((response: { songURL: string, coverURL: string, title: string }) => {
        const media = {
            url: response.songURL,
            cover: {
                title: response.title,
                url: response.coverURL
            }
        }

        device.play(media, (err: any) => {
            if (err) {
                console.log(err);
            }
        });
    }).catch((err: any) => {
        console.log(err);
    });
});
}