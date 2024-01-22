import Client = require('chromecast-api');
import  Device  from 'chromecast-api';

export function getChromecasts(client: Client) {
	const chromecasts: string[] = client.devices.map((device: Device) => device.friendlyName);
	return { 'status': 'ok', 'response': chromecasts };
}

export function getChromecast(client: Client, chromecastName: string){
	const device = client.devices.find((device: Device) => device.friendlyName === chromecastName);
	return device;
}