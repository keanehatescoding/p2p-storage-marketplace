-- Policy for pre-existing out-of-range ratings: archive them verbatim,
-- remove them from `reviews`, then add the constraint. Valid rows are
-- untouched; invalid values are preserved in the archive rather than
-- silently clamped or discarded. Run the SELECT first to audit what will
-- be moved on a deployment with existing data:
--   SELECT id, rating FROM reviews WHERE rating NOT BETWEEN 1 AND 5;
CREATE TABLE IF NOT EXISTS "reviews_invalid_rating_archive" (
  "id" uuid PRIMARY KEY,
  "booking_id" uuid NOT NULL,
  "author_id" uuid NOT NULL,
  "rating" integer NOT NULL,
  "archived_at" timestamptz NOT NULL DEFAULT now()
);

INSERT INTO "reviews_invalid_rating_archive"
  ("id", "booking_id", "author_id", "rating")
SELECT "id", "booking_id", "author_id", "rating"
  FROM "reviews"
  WHERE "rating" NOT BETWEEN 1 AND 5;

DELETE FROM "reviews" WHERE "rating" NOT BETWEEN 1 AND 5;

ALTER TABLE "reviews" ADD CONSTRAINT "reviews_rating_range"
  CHECK ("rating" between 1 and 5);
