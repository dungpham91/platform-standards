const fs = require("fs");
const path = require("path");

const root = path.join(__dirname, "..");
const dist = path.join(root, "dist");
const src = path.join(root, "public", "index.html");

fs.mkdirSync(dist, { recursive: true });
fs.copyFileSync(src, path.join(dist, "index.html"));
console.log("Built static site to dist/");
