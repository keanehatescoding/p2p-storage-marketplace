import { desc, eq } from "drizzle-orm";
import { db, type Listing, listings } from "@/db";

export const dynamic = "force-dynamic";

const kindLabels: Record<Listing["kind"], string> = {
  garage: "Garage",
  spare_room: "Spare room",
  basement: "Basement",
  warehouse: "Warehouse",
  self_storage_unit: "Self-storage unit",
  backyard: "Backyard",
};

function formatKes(amount: number): string {
  return `KSh ${amount.toLocaleString("en-KE")}`;
}

async function getPublishedListings(): Promise<Listing[] | null> {
  try {
    return await db
      .select()
      .from(listings)
      .where(eq(listings.published, true))
      .orderBy(desc(listings.createdAt))
      .limit(24);
  } catch {
    return null;
  }
}

export default async function HomePage() {
  const published = await getPublishedListings();

  return (
    <div className="space-y-10">
      <section className="space-y-3">
        <h1 className="text-3xl font-semibold">Storage space, without the warehouse.</h1>
        <p className="max-w-2xl text-stone-600">
          Rent a spare garage, room or warehouse corner from a verified host, or list your
          own space and earn monthly income.
        </p>
      </section>

      <section className="space-y-4">
        <h2 className="text-xl font-semibold">Available spaces</h2>
        {published === null ? (
          <p className="text-stone-600">
            Listings are unavailable right now. Check the database connection and try again.
          </p>
        ) : published.length === 0 ? (
          <p className="text-stone-600">No spaces are published yet.</p>
        ) : (
          <ul className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
            {published.map((listing) => (
              <li key={listing.id} className="rounded-lg border border-stone-200 bg-white p-4">
                <p className="text-sm text-stone-500">{kindLabels[listing.kind]}</p>
                <h3 className="mt-1 text-lg font-medium">{listing.title}</h3>
                <p className="mt-1 text-sm text-stone-600">
                  {listing.neighbourhood}, {listing.town}
                </p>
                <p className="mt-3 font-semibold">
                  {formatKes(listing.monthlyPriceKes)}
                  <span className="font-normal text-stone-500"> / month</span>
                </p>
                <p className="mt-1 text-sm text-stone-500">
                  {listing.sizeSquareMetres} m²
                  {listing.hasCctv ? " · CCTV" : ""}
                  {listing.hasGate ? " · Gated" : ""}
                </p>
              </li>
            ))}
          </ul>
        )}
      </section>
    </div>
  );
}
