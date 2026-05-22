import Fastify from "fastify";
import { Pool } from "pg";
import { createClient } from "redis";

const fastify = Fastify({ logger: true });

const pool = new Pool({
   host: process.env.DB_HOST,
   user: process.env.DB_USER,
   password: process.env.DB_PASSWORD,
   database: process.env.DB_NAME,
   port: 5432,
});

const redis = createClient({
   url: `redis://${process.env.REDIS_HOST}:6379`,
});

await redis.connect();

// init DB
await pool.query(`
  CREATE TABLE IF NOT EXISTS notes (
    id SERIAL PRIMARY KEY,
    text TEXT NOT NULL
  )
`);

fastify.get("/health", async () => {
   return { status: "ok" };
});

fastify.post<{ Body: { text: string } }>("/notes", async (req) => {
   const { text } = req.body;

   const result = await pool.query(
      "INSERT INTO notes(text) VALUES($1) RETURNING *",
      [text]
   );

   await redis.del("notes:all");

   return result.rows[0];
});

fastify.get("/notes", async () => {
   const cached = await redis.get("notes:all");
   if (cached) return JSON.parse(cached);

   const result = await pool.query("SELECT * FROM notes ORDER BY id DESC");

   await redis.set("notes:all", JSON.stringify(result.rows));

   return result.rows;
});

await fastify.listen({ port: 3000, host: "0.0.0.0" });