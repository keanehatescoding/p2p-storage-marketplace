import { Pool } from "pg";

const databaseUrl = process.env.DATABASE_URL;
if (!databaseUrl) {
  throw new Error("DATABASE_URL is not set");
}

const pool = new Pool({ connectionString: databaseUrl });

try {
  // Add seed data here as the project develops.
  console.log("No seed data defined");
} finally {
  await pool.end();
}
