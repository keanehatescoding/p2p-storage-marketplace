-- Policy for pre-existing out-of-range ratings: archive them verbatim,
-- remove them from `reviews`, then add the CHECK constraint. Valid rows are
-- untouched; invalid values are preserved in the archive rather than
-- silently clamped or discarded. Run the SELECT first to audit what will
-- be moved on a deployment with existing data:
--   SELECT id, rating FROM reviews WHERE rating NOT BETWEEN 1 AND 5;
CREATE TABLE IF NOT EXISTS "reviews_invalid_rating_archive" (
  "id" uuid PRIMARY KEY,
  "booking_id" uuid NOT NULL,
  "author_id" uuid NOT NULL,
  "rating" integer NOT NULL,
  "body" text NOT NULL,
  "created_at" timestamptz NOT NULL,
  "archived_at" timestamptz NOT NULL DEFAULT now()
);

-- One statement: DELETE RETURNING feeds exactly the rows it removed into
-- the archive, so a concurrent writer cannot slip a row between the two
-- snapshots under READ COMMITTED.
WITH removed AS (
  DELETE FROM "reviews" WHERE "rating" NOT BETWEEN 1 AND 5
  RETURNING "id", "booking_id", "author_id", "rating", "body", "created_at"
)
INSERT INTO "reviews_invalid_rating_archive"
  ("id", "booking_id", "author_id", "rating", "body", "created_at")
SELECT "id", "booking_id", "author_id", "rating", "body", "created_at"
  FROM removed;

-- NOT VALID avoids holding ACCESS EXCLUSIVE while scanning existing rows;
-- 0002 validates it in a separate transaction.
ALTER TABLE "reviews" ADD CONSTRAINT "reviews_rating_range"
  CHECK ("rating" between 1 and 5) NOT VALID;
