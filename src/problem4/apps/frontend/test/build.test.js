const { describe, it } = require("node:test");
const assert = require("node:assert/strict");
const fs = require("fs");
const path = require("path");
const { execSync } = require("node:child_process");

const appRoot = path.join(__dirname, "..");

describe("frontend build", () => {
  it("produces index.html", () => {
    execSync("npm run build", { cwd: appRoot, stdio: "pipe" });
    const out = path.join(appRoot, "dist", "index.html");
    assert.ok(fs.existsSync(out));
    assert.match(fs.readFileSync(out, "utf8"), /Trading Console/);
  });
});
