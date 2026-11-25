CREATE TYPE "public"."booking_status" AS ENUM('requested', 'accepted', 'declined', 'active', 'ended', 'cancelled');--> statement-breakpoint
CREATE TYPE "public"."listing_kind" AS ENUM('garage', 'spare_room', 'basement', 'warehouse', 'self_storage_unit', 'backyard');--> statement-breakpoint
CREATE TYPE "public"."payout_status" AS ENUM('pending', 'paid', 'failed');--> statement-breakpoint
CREATE TABLE "bookings" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"listing_id" uuid NOT NULL,
	"renter_id" uuid NOT NULL,
	"status" "booking_status" DEFAULT 'requested' NOT NULL,
	"starts_on" date NOT NULL,
	"ends_on" date,
	"monthly_price_kes" integer NOT NULL,
	"deposit_kes" integer DEFAULT 0 NOT NULL,
	"inventory_manifest" text DEFAULT '' NOT NULL,
	"cancelled_at" timestamp with time zone,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "inspections" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"booking_id" uuid NOT NULL,
	"kind" text NOT NULL,
	"performed_at" timestamp with time zone NOT NULL,
	"notes" text DEFAULT '' NOT NULL,
	"photos" text[] DEFAULT '{}'::text[] NOT NULL,
	"signed_by_host" boolean DEFAULT false NOT NULL,
	"signed_by_renter" boolean DEFAULT false NOT NULL
);
--> statement-breakpoint
CREATE TABLE "listing_photos" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"listing_id" uuid NOT NULL,
	"url" text NOT NULL,
	"caption" text DEFAULT '' NOT NULL,
	"sort_order" integer DEFAULT 0 NOT NULL
);
--> statement-breakpoint
CREATE TABLE "listings" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"host_id" uuid NOT NULL,
	"kind" "listing_kind" NOT NULL,
	"title" text NOT NULL,
	"description" text NOT NULL,
	"neighbourhood" text NOT NULL,
	"town" text NOT NULL,
	"size_square_metres" integer NOT NULL,
	"monthly_price_kes" integer NOT NULL,
	"price_per_day_kes" integer,
	"has_cctv" boolean DEFAULT false NOT NULL,
	"has_gate" boolean DEFAULT false NOT NULL,
	"access_hours" text DEFAULT '24/7' NOT NULL,
	"max_items" integer,
	"published" boolean DEFAULT false NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "payouts" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"host_id" uuid NOT NULL,
	"booking_id" uuid NOT NULL,
	"status" "payout_status" DEFAULT 'pending' NOT NULL,
	"amount_kes" integer NOT NULL,
	"fee_kes" integer DEFAULT 0 NOT NULL,
	"channel" text DEFAULT 'mpesa' NOT NULL,
	"external_ref" text,
	"paid_at" timestamp with time zone,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "reviews" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"booking_id" uuid NOT NULL,
	"author_id" uuid NOT NULL,
	"rating" integer NOT NULL,
	"body" text DEFAULT '' NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "sessions" (
	"id" text PRIMARY KEY NOT NULL,
	"user_id" uuid NOT NULL,
	"expires_at" timestamp with time zone NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "users" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"email" text NOT NULL,
	"name" text NOT NULL,
	"phone" text,
	"password_hash" text NOT NULL,
	"email_verified_at" timestamp with time zone,
	"kyc_verified_at" timestamp with time zone,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
ALTER TABLE "bookings" ADD CONSTRAINT "bookings_listing_id_listings_id_fk" FOREIGN KEY ("listing_id") REFERENCES "public"."listings"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "bookings" ADD CONSTRAINT "bookings_renter_id_users_id_fk" FOREIGN KEY ("renter_id") REFERENCES "public"."users"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "inspections" ADD CONSTRAINT "inspections_booking_id_bookings_id_fk" FOREIGN KEY ("booking_id") REFERENCES "public"."bookings"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "listing_photos" ADD CONSTRAINT "listing_photos_listing_id_listings_id_fk" FOREIGN KEY ("listing_id") REFERENCES "public"."listings"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "listings" ADD CONSTRAINT "listings_host_id_users_id_fk" FOREIGN KEY ("host_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "payouts" ADD CONSTRAINT "payouts_host_id_users_id_fk" FOREIGN KEY ("host_id") REFERENCES "public"."users"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "payouts" ADD CONSTRAINT "payouts_booking_id_bookings_id_fk" FOREIGN KEY ("booking_id") REFERENCES "public"."bookings"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "reviews" ADD CONSTRAINT "reviews_booking_id_bookings_id_fk" FOREIGN KEY ("booking_id") REFERENCES "public"."bookings"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "reviews" ADD CONSTRAINT "reviews_author_id_users_id_fk" FOREIGN KEY ("author_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "sessions" ADD CONSTRAINT "sessions_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
CREATE INDEX "bookings_listing_idx" ON "bookings" USING btree ("listing_id","starts_on");--> statement-breakpoint
CREATE INDEX "bookings_renter_idx" ON "bookings" USING btree ("renter_id","starts_on");--> statement-breakpoint
CREATE INDEX "inspections_booking_idx" ON "inspections" USING btree ("booking_id");--> statement-breakpoint
CREATE INDEX "listing_photos_listing_idx" ON "listing_photos" USING btree ("listing_id");--> statement-breakpoint
CREATE INDEX "listings_town_published_idx" ON "listings" USING btree ("town","published");--> statement-breakpoint
CREATE INDEX "listings_host_idx" ON "listings" USING btree ("host_id");--> statement-breakpoint
CREATE INDEX "payouts_host_idx" ON "payouts" USING btree ("host_id","created_at");--> statement-breakpoint
CREATE UNIQUE INDEX "reviews_booking_author_idx" ON "reviews" USING btree ("booking_id","author_id");--> statement-breakpoint
CREATE INDEX "sessions_user_idx" ON "sessions" USING btree ("user_id");--> statement-breakpoint
CREATE UNIQUE INDEX "users_email_lower_idx" ON "users" USING btree (lower("email"));