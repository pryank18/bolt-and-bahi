# Bolt & Bahi

A textile trade ledger built for Indian fabric traders - retail counter billing, wholesale distribution, job work tracking, dispatch and logistics, GST-correct invoicing (CGST/SGST/IGST handled automatically), supplier payables, customer aging, and ARA, a built-in assistant that understands the ledger and can draft reminders, summarize the day, and read a fabric photo straight into stock. Ten languages, including Hinglish. Five visual themes. Built to run on a single device with everything saved locally, no account or subscription required to use it.

## Where this project actually stands right now

Being upfront about this rather than describing a finished product:

The running app (bolt-and-bahi.jsx) is a single-file React prototype built to run as a Claude.ai artifact. It stores all data locally in the browser (no backend), and its "Organization / Roles" feature is an explicitly labeled concept preview - shared PINs per role, not real individual logins.

The Supabase schema (supabase/schema.sql) is built, deployed to a live project, and independently verified: all 21 tables, 6 helper functions, 24 RLS policies, and 5 column-masking views are confirmed present and working, including a passing end-to-end seed test.

These two are not yet connected. The prototype does not talk to Supabase yet. Migrating the frontend to a real Vite project backed by this schema, with real Supabase Auth replacing the shared-PIN system, is the next phase of work, not something already shipped. See Roadmap below.

If you're looking at this repo expecting a finished multi-user backend app, it isn't that yet. What's here today is a working single-device prototype plus a verified, ready-to-use database schema for where it's headed.

## Running the prototype today

The prototype is built to run as a Claude.ai artifact and depends on two things only available in that environment:

- window.storage for local persistence (not a standard browser API)
- Anthropic API access for the AI features (ARA, fabric photo-fill, dashboard insights, payment reminders), authenticated automatically by the Claude.ai platform - no key needed inside that environment

Outside Claude.ai, in a plain browser, persistence and every AI feature will not function without further changes (see Roadmap). To actually use the app today, open bolt-and-bahi.jsx as a Claude.ai artifact.

## Setting up the Supabase schema

If you want your own copy of the database (for development against the planned Vite frontend, or to inspect/extend the schema):

1. Create a new Supabase project (free tier is enough for a single business's ledger)
2. Open the SQL Editor, paste the full contents of supabase/schema.sql, run it once
3. Verify it landed correctly:

```sql
-- expect exactly 6, all named auth_* or seed_default_roles
select routine_name from information_schema.routines where routine_schema = 'public' and routine_type = 'FUNCTION';

-- expect 21 rows, all rowsecurity = true
select tablename, rowsecurity from pg_tables where schemaname = 'public';

-- expect exactly 24
select count(*) from pg_policies where schemaname = 'public';
```

Copy .env.example to .env.local and fill in your project's URL and anon key from Project Settings -> API

Use a project of your own, not a shared one. This schema creates 21 tables and 24 policies in the public schema of whatever project you run it against - don't run it against a Supabase project that's already serving another application.

## Roadmap

In rough order:

- [ ] Migration importer - read the existing JSON backup format (already exportable from the prototype's Settings tab) and insert it into the new schema
- [ ] Restructure into a real Vite + React project (the artifact format can't install npm packages like @supabase/supabase-js)
- [ ] Replace all local-storage persistence with real Supabase queries
- [ ] Replace the shared-PIN role system with real Supabase Auth - individual logins per staff member instead of one PIN per role
- [ ] Real-time sync across devices via Supabase Realtime
- [ ] A "bring your own Anthropic API key" field in Settings, so the AI features work outside the Claude.ai artifact environment too
- [ ] A real test suite (Vitest) and CI, so regressions get caught automatically instead of by hand

## License

MIT - see LICENSE. Free to use, modify, and redistribute.
