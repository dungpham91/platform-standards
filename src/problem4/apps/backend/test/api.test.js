const { describe, it } = require("node:test");
const assert = require("node:assert/strict");
const http = require("node:http");

const app = require("../src/index");

function request(method, path, headers = {}) {
  return new Promise((resolve, reject) => {
    const server = app.listen(0, () => {
      const { port } = server.address();
      const req = http.request(
        {
          hostname: "127.0.0.1",
          method,
          path,
          port,
          headers,
        },
        (res) => {
          let body = "";
          res.on("data", (chunk) => {
            body += chunk;
          });
          res.on("end", () => {
            server.close();
            let parsed = null;
            if (body) {
              try {
                parsed = JSON.parse(body);
              } catch {
                parsed = { raw: body };
              }
            }
            resolve({
              body: parsed,
              status: res.statusCode,
            });
          });
        },
      );
      req.on("error", reject);
      req.end();
    });
  });
}

describe("trading API", () => {
  it("GET /health returns ok", async () => {
    const res = await request("GET", "/health");
    assert.equal(res.status, 200);
    assert.equal(res.body.status, "ok");
  });

  it("GET /api/version returns version field", async () => {
    const res = await request("GET", "/api/version");
    assert.equal(res.status, 200);
    assert.ok(res.body.version);
  });

  it("rejects disallowed CORS origin with 403 JSON", async () => {
    const res = await request("GET", "/health", {
      Origin: "https://evil.example",
    });
    assert.equal(res.status, 403);
    assert.equal(res.body.error, "CORS blocked");
  });
});
