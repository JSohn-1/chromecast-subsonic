export function getChromecasts(client: any) {
    const chromecasts = client.devices.map((device: any) => device.friendlyName);
    return { "status": "ok", "response": chromecasts };
}