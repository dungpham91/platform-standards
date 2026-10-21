const { describe, it } = require("node:test");
const assert = require("node:assert/strict");
const path = require("path");
const { execSync } = require("node:child_process");

const appRoot = path.join(__dirname, "..");

describe("frontend lint", () => {
  it("build script has valid syntax", () => {
    execSync("node --check scripts/build.js", { cwd: appRoot, stdio: "pipe" });
    assert.ok(true);
  });
});
