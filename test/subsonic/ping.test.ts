// Test the ping endpoint

import { expect, test } from "bun:test";
import { ping } from "../../src/subsonic/ping";
test("Ping endpoint should return 'pong' when status is 'ok'", async () => {
    // Arrange

    // Act
    const result = await ping();

    // Assert
    expect(result).toEqual(JSON.stringify({ status: "ok", response: "pong" }));
});


