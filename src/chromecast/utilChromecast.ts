import Client = require('chromecast-api');

export function getChromecasts(client: Client) {
    const chromecasts = client.devices.map((device: any) => device.friendlyName);
    return { "status": "ok", "response": chromecasts };
}

export function getChromecast(client: Client, chromecastName: string){
    const device = client.devices.find((device: any) => device.friendlyName === chromecastName);
    return device;
}