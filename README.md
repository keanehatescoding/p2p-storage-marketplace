# Peer-to-peer storage marketplace

- **Concept:** An asset-light marketplace matching people with spare space (a garage, a spare room, unused warehouse corners) to people needing short- or medium-term storage — distinct from operating a storage facility yourself.
- **Origin:** Neighbor.com (US), a VC-backed peer-to-peer storage marketplace.
- **Kenya landscape:** Kenya's existing self-storage players — Storage Central (raised a $20M+ expansion round, opened its first facility on Mombasa Road in 2020) and Crown Relo — are capital-heavy facility operators who build and own warehouses. A 2017 industry account confirmed that before Storage Central, "there were no self-storage operators in Kenya" at all, only moving/security companies. The asset-light marketplace variant — matching existing spare space rather than building new facilities — has not been tried.
- **Opportunity:** A genuinely low-capital alternative to the facility-building model already being pursued by well-funded operators.
- **Target customers:** Urban apartment dwellers downsizing or moving, SMEs needing overflow inventory space (hosts = anyone with spare garage/room space to rent out).
- **Revenue model:** Commission/take-rate on each booking, with an optional insurance upsell for stored goods.
- **Difficulty:** Low–Medium — primarily a trust-and-safety/marketplace product (listings, verification, payments); no facility capex required.
- **Scalability:** Medium — works best in dense urban markets with genuine space scarcity (Nairobi, Mombasa).
- **Risks:** Trust is the core challenge on both sides (hosts worried about goods causing problems, seekers worried about security); needs a strong verification and insurance layer to feel safe.
- **MVP:** A simple two-sided listing site for one Nairobi neighborhood, monthly bookings, with M-Pesa payment coordinated manually at first.

---

Source: `PROJECTS.md` (Online Business Models: Proven Abroad, Underdeveloped in Kenya).


---

## Stack & dev

Scaffolded as a Next.js 16 + Drizzle (Postgres) app, matching the stack used in `odpc-compliance-saas`. The schema in `src/db/schema.ts` is the current source of truth for the data model; UI, auth and payment integrations are not yet wired up.

```
npm install
# point .env at a Postgres instance, see .env.example
npm run db:generate   # drizzle-kit: emit SQL migrations from the schema
npm run db:migrate    # apply migrations from ./drizzle
npm run dev           # Next.js dev server on :3000
```

What is here:
- `src/db/schema.ts` — Drizzle Postgres schema specific to this domain
- `src/db/index.ts` — pooled `pg` + Drizzle client
- `drizzle.config.ts`, `next.config.ts`, `tsconfig.json`, `eslint.config.mjs`, `postcss.config.mjs`
- `src/app/globals.css`, `.gitignore`, `.env.example`

What is still a stub:
- `src/app/layout.tsx` + `src/app/page.tsx` — scaffold against the installed Next version (see `node_modules/next/dist/docs/`); the `odpc-compliance-saas` siblings are a working reference.
- Auth (sessions, password reset, email verify) — copy and adapt the `lib/session.ts`, `lib/password.ts`, `lib/email-verification.ts` set from `odpc-compliance-saas`.
- Payments (M-Pesa Daraja / Paystack / card) — stack-specific, add per project.
- Seed data in `scripts/seed.ts` — placeholder only.
