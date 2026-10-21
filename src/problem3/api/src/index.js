const express = require("express");

const app = express();

let pool;
let redisClient;

function getPool() {
  if (!process.env.DB_HOST) {
    throw new Error("DB_HOST is not configured");
  }
  if (!pool) {
    const { Pool } = require("pg");
    pool = new Pool({
      host: process.env.DB_HOST,
      user: "postgres",
      password: "postgres",
      database: "postgres",
      port: 5432,
    });
  }
  return pool;
}

function getRedis() {
  if (!process.env.REDIS_HOST) {
    throw new Error("REDIS_HOST is not configured");
  }
  if (!redisClient) {
    const Redis = require("ioredis");
    redisClient = new Redis({
      host: process.env.REDIS_HOST,
      port: 6379,
      maxRetriesPerRequest: 2,
      lazyConnect: true,
      enableOfflineQueue: false,
      retryStrategy: () => null,
    });
  }
  return redisClient;
}

async function ensureRedisReady(client) {
  if (client.status === "ready") {
    return;
  }
  await client.connect();
}

app.get("/api/users", async (req, res) => {
  try {
    const db = await getPool().connect();
    const result = await db.query("SELECT NOW()");
    db.release();

    const redis = getRedis();
    await ensureRedisReady(redis);
    await redis.set("last_call", String(Date.now()));
    res.json({ ok: true, time: result.rows[0] });
  } catch (err) {
    console.error(err);
    res.status(500).json({ ok: false, error: err.message });
  }
});

app.get("/status", (req, res) => {
  res.json({ status: "ok" });
});

function shutdown() {
  if (pool) {
    pool.end().catch(() => {});
  }
  if (redisClient) {
    redisClient.disconnect();
  }
}

if (require.main === module) {
  const port = Number(process.env.PORT || 3000);
  const server = app.listen(port, () => console.log(`API listening on ${port}`));
  process.on("SIGTERM", () => {
    server.close(() => {
      shutdown();
      process.exit(0);
    });
  });
}

module.exports = app;
