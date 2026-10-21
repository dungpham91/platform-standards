const { describe, it } = require("node:test");
const assert = require("node:assert/strict");
const http = require("node:http");

const app = require("../src/index");

describe("problem3 API", () => {
  it("GET /status returns ok", async () => {
    await new Promise((resolve, reject) => {
      const server = app.listen(0, () => {
        const { port } = server.address();
        http
          .get(`http://127.0.0.1:${port}/status`, (res) => {
            let body = "";
            res.on("data", (c) => {
              body += c;
            });
            res.on("end", () => {
              server.close();
              assert.equal(res.statusCode, 200);
              assert.equal(JSON.parse(body).status, "ok");
              resolve();
            });
          })
          .on("error", reject);
      });
    });
  });
});
