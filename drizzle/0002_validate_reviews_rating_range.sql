-- Separate transaction from 0001 so the ACCESS EXCLUSIVE held while adding
-- the constraint is released before the validating scan runs.
ALTER TABLE "reviews" VALIDATE CONSTRAINT "reviews_rating_range";
