-- Prevent bookings whose end date precedes their start date. Open-ended
-- rentals keep `ends_on` NULL, so the constraint only applies when an end
-- date is supplied.
ALTER TABLE "bookings" ADD CONSTRAINT "bookings_date_range"
  CHECK ("ends_on" IS NULL OR "ends_on" >= "starts_on");