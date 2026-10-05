import { relations, sql } from "drizzle-orm";
import {
  boolean,
  date,
  index,
  integer,
  pgEnum,
  pgTable,
  text,
  timestamp,
  uniqueIndex,
  uuid,
} from "drizzle-orm/pg-core";

export const listingKindEnum = pgEnum("listing_kind", [
  "garage",
  "spare_room",
  "basement",
  "warehouse",
  "self_storage_unit",
  "backyard",
]);
export const bookingStatusEnum = pgEnum("booking_status", [
  "requested",
  "accepted",
  "declined",
  "active",
  "ended",
  "cancelled",
]);
export const payoutStatusEnum = pgEnum("payout_status", ["pending", "paid", "failed"]);

const timestamps = {
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
  updatedAt: timestamp("updated_at", { withTimezone: true })
    .notNull()
    .defaultNow()
    .$onUpdate(() => new Date()),
};

export const users = pgTable(
  "users",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    email: text("email").notNull(),
    name: text("name").notNull(),
    phone: text("phone"),
    passwordHash: text("password_hash").notNull(),
    emailVerifiedAt: timestamp("email_verified_at", { withTimezone: true }),
    // KYC gate: hosts must upload ID before payouts; renters must verify before booking.
    kycVerifiedAt: timestamp("kyc_verified_at", { withTimezone: true }),
    ...timestamps,
  },
  (t) => [uniqueIndex("users_email_lower_idx").on(sql`lower(${t.email})`)],
);

export const sessions = pgTable(
  "sessions",
  {
    id: text("id").primaryKey(),
    userId: uuid("user_id")
      .notNull()
      .references(() => users.id, { onDelete: "cascade" }),
    expiresAt: timestamp("expires_at", { withTimezone: true }).notNull(),
    createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
  },
  (t) => [index("sessions_user_idx").on(t.userId)],
);

export const listings = pgTable(
  "listings",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    hostId: uuid("host_id")
      .notNull()
      .references(() => users.id, { onDelete: "cascade" }),
    kind: listingKindEnum("kind").notNull(),
    title: text("title").notNull(),
    description: text("description").notNull(),
    neighbourhood: text("neighbourhood").notNull(),
    town: text("town").notNull(),
    sizeSquareMetres: integer("size_square_metres").notNull(),
    // Monthly price in KES. Day/week pricing derives from this.
    monthlyPriceKes: integer("monthly_price_kes").notNull(),
    pricePerDayKes: integer("price_per_day_kes"),
    hasCctv: boolean("has_cctv").notNull().default(false),
    hasGate: boolean("has_gate").notNull().default(false),
    accessHours: text("access_hours").notNull().default("24/7"),
    maxItems: integer("max_items"),
    published: boolean("published").notNull().default(false),
    ...timestamps,
  },
  (t) => [
    index("listings_town_published_idx").on(t.town, t.published),
    index("listings_host_idx").on(t.hostId),
  ],
);

export const listingPhotos = pgTable(
  "listing_photos",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    listingId: uuid("listing_id")
      .notNull()
      .references(() => listings.id, { onDelete: "cascade" }),
    url: text("url").notNull(),
    caption: text("caption").notNull().default(""),
    sortOrder: integer("sort_order").notNull().default(0),
  },
  (t) => [index("listing_photos_listing_idx").on(t.listingId)],
);

export const bookings = pgTable(
  "bookings",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    listingId: uuid("listing_id")
      .notNull()
      .references(() => listings.id, { onDelete: "restrict" }),
    renterId: uuid("renter_id")
      .notNull()
      .references(() => users.id, { onDelete: "restrict" }),
    status: bookingStatusEnum("status").notNull().default("requested"),
    startsOn: date("starts_on", { mode: "string" }).notNull(),
    // Open-ended rentals: null `endsOn` means month-to-month.
    endsOn: date("ends_on", { mode: "string" }),
    monthlyPriceKes: integer("monthly_price_kes").notNull(),
    depositKes: integer("deposit_kes").notNull().default(0),
    inventoryManifest: text("inventory_manifest").notNull().default(""),
    cancelledAt: timestamp("cancelled_at", { withTimezone: true }),
    ...timestamps,
  },
  (t) => [
    index("bookings_listing_idx").on(t.listingId, t.startsOn),
    index("bookings_renter_idx").on(t.renterId, t.startsOn),
  ],
);

/** Walk-through at move-in and move-out, with photos. Protects both parties on claims. */
export const inspections = pgTable(
  "inspections",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    bookingId: uuid("booking_id")
      .notNull()
      .references(() => bookings.id, { onDelete: "cascade" }),
    kind: text("kind").notNull(),
    performedAt: timestamp("performed_at", { withTimezone: true }).notNull(),
    notes: text("notes").notNull().default(""),
    photos: text("photos").array().notNull().default(sql`'{}'::text[]`),
    signedByHost: boolean("signed_by_host").notNull().default(false),
    signedByRenter: boolean("signed_by_renter").notNull().default(false),
  },
  (t) => [index("inspections_booking_idx").on(t.bookingId)],
);

export const payouts = pgTable(
  "payouts",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    hostId: uuid("host_id")
      .notNull()
      .references(() => users.id, { onDelete: "restrict" }),
    bookingId: uuid("booking_id")
      .notNull()
      .references(() => bookings.id, { onDelete: "restrict" }),
    status: payoutStatusEnum("status").notNull().default("pending"),
    amountKes: integer("amount_kes").notNull(),
    feeKes: integer("fee_kes").notNull().default(0),
    channel: text("channel").notNull().default("mpesa"),
    externalRef: text("external_ref"),
    paidAt: timestamp("paid_at", { withTimezone: true }),
    ...timestamps,
  },
  (t) => [index("payouts_host_idx").on(t.hostId, t.createdAt)],
);

export const reviews = pgTable(
  "reviews",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    bookingId: uuid("booking_id")
      .notNull()
      .references(() => bookings.id, { onDelete: "cascade" }),
    authorId: uuid("author_id")
      .notNull()
      .references(() => users.id, { onDelete: "cascade" }),
    rating: integer("rating").notNull(),
    body: text("body").notNull().default(""),
    createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
  },
  (t) => [uniqueIndex("reviews_booking_author_idx").on(t.bookingId, t.authorId)],
);

export const listingRelations = relations(listings, ({ one, many }) => ({
  host: one(users, { fields: [listings.hostId], references: [users.id] }),
  photos: many(listingPhotos),
  bookings: many(bookings),
}));

export const bookingRelations = relations(bookings, ({ one, many }) => ({
  listing: one(listings, { fields: [bookings.listingId], references: [listings.id] }),
  renter: one(users, { fields: [bookings.renterId], references: [users.id] }),
  inspections: many(inspections),
  payouts: many(payouts),
  reviews: many(reviews),
}));

export type Listing = typeof listings.$inferSelect;
export type Booking = typeof bookings.$inferSelect;
export type Inspection = typeof inspections.$inferSelect;
export type Payout = typeof payouts.$inferSelect;
export type Review = typeof reviews.$inferSelect;
