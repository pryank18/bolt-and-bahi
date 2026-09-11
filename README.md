# Bolt & Bahi

A textile trade ledger built for Indian fabric traders — retail counter
billing, wholesale distribution, job work tracking, dispatch and logistics,
GST-correct invoicing (CGST/SGST/IGST handled automatically), supplier
payables, customer aging, and ARA, a built-in assistant that understands
the ledger and can draft reminders, summarize the day, and read a fabric
photo straight into stock. Ten languages, including Hinglish. Five visual
themes. Everything saved locally, no account or subscription required to
use it.

## Where this project actually stands right now

Being upfront about this rather than describing a finished product:

- **`/app`** is a real, standalone Vite + React project. It builds and
  runs in a plain browser — no Claude.ai dependency. Data persists to
  real browser `localStorage`. AI features (ARA, fabric photo-fill,
  dashboard insights, reminder drafting) work once you add your own
  Anthropic API key in the app's Settings tab (bring-your-own-key —
  nothing is billed to anyone but you, and the key never leaves your
  browser except in direct calls to Anthropic).
- **`/prototype`** is the original single-file version this was built
  from, kept for reference. It only runs as a Claude.ai artifact.
- **`/supabase/schema.sql`** is a real, independently verified schema —
  21 tables, 6 functions, 24 RLS policies, 5 masking views — deployed
  and confirmed working on its own Supabase project.
- **`/app` and Supabase are not connected yet.** `/app` currently
  persists to `localStorage` only. Wiring it to the verified schema —
  real accounts, real multi-device sync, real per-role security enforced
  by the database instead of the UI — is the next phase. The
  "Organization / Roles" feature in the app today is still a labeled
  **concept preview**: shared PINs per role, not real individual logins.

What's here today: a real, working, single-device app you can build, run,
and deploy right now, plus a verified database schema ready for the next
phase connecting them.

## Running it

```bash
cd app
npm install
npm run dev
```

Open the printed local URL. To use the AI features, go to Settings and
add your own Anthropic API key — get one at
[console.anthropic.com](https://console.anthropic.com). Your key is
stored only in your browser and used only for your own requests.

To build for deployment (Vercel, Netlify, GitHub Pages, or any static
host):

```bash
cd app
npm run build
```

Output lands in `app/dist/` — deploy that folder as a static site.

## Setting up the Supabase schema

Not required to run the app today — this is for the next phase of work
(see Roadmap). If you want your own copy of the database:

1. Create a new Supabase project (free tier is enough for a single
   business's ledger)
2. Open the SQL Editor, paste the full contents of `supabase/schema.sql`,
   run it once
3. Verify it landed correctly:

   ```sql
   -- expect exactly 6, all named auth_* or seed_default_roles
   select routine_name from information_schema.routines
   where routine_schema = 'public' and routine_type = 'FUNCTION';

   -- expect 21 rows, all rowsecurity = true
   select tablename, rowsecurity from pg_tables where schemaname = 'public';

   -- expect exactly 24
   select count(*) from pg_policies where schemaname = 'public';
   ```

4. Copy `app/.env.example` to `app/.env.local` and fill in your project's
   URL and anon key from Project Settings -> API

**Use a project of your own, not a shared one.** This schema creates 21
tables and 24 policies in the `public` schema of whatever project you run
it against — don't run it against a Supabase project that's already
serving another application.

## Roadmap

- [x] Restructure into a real Vite + React project
- [x] A "bring your own Anthropic API key" field, so AI features work
      outside Claude.ai
- [ ] Migration importer — read the existing JSON backup format (already
      exportable from the app's Settings tab) and insert it into the
      Supabase schema
- [ ] Replace `localStorage` persistence with real Supabase queries
- [ ] Replace the shared-PIN role system with real Supabase Auth —
      individual logins per staff member instead of one PIN per role
- [ ] Real-time sync across devices via Supabase Realtime
- [ ] A real test suite (Vitest) and CI, so regressions get caught
      automatically instead of by hand

## License

MIT — see `LICENSE`. Free to use, modify, and redistribute.
