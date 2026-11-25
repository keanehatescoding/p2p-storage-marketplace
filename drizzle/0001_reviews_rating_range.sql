ALTER TABLE "reviews" ADD CONSTRAINT "reviews_rating_range" CHECK ("rating" between 1 and 5);
