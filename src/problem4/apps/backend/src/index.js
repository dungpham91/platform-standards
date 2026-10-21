const cors = require("cors");
const express = require("express");
const helmet = require("helmet");

const app = express();

const port = Number(process.env.PORT || 3000);
const allowedOrigins = (process.env.CORS_ORIGINS || "http://localhost:8080")
  .split(",")
  .map((o) => o.trim())
  .filter(Boolean);

app.disable("x-powered-by");
app.use(
  helmet({
    contentSecurityPolicy: false,
    crossOriginResourcePolicy: { policy: "same-site" },
  }),
);
app.use(
  cors({
    origin(origin, callback) {
      if (!origin || allowedOrigins.includes(origin)) {
        callback(null, true);
        return;
      }
      callback(new Error("CORS blocked"));
    },
    credentials: true,
  }),
);

app.get("/health", (_req, res) => {
  res.json({ status: "ok" });
});

app.get("/api/version", (_req, res) => {
  res.json({ version: process.env.APP_VERSION || "dev" });
});

app.use((err, _req, res, next) => {
  if (res.headersSent) {
    next(err);
    return;
  }
  if (err.message === "CORS blocked") {
    res.status(403).json({ error: "CORS blocked" });
    return;
  }
  next(err);
});

if (require.main === module) {
  app.listen(port, () => console.log(`API listening on ${port}`));
}

module.exports = app;
