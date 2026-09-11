# Working on Bolt & Bahi — read this first

This file is for any AI coding agent (or human contributor) picking up this repo — it follows the AGENTS.md convention read by most current coding assistants. It exists because a lot of hard-won, specific context from the original build would otherwise be lost the moment a new session starts cold. Read it before making changes, not after something breaks.

## What this actually is right now — don't overstate it

`bolt-and-bahi.jsx` is a single-file React app, built to run as a Claude.ai artifact. It persists data via `window.storage` (an artifact-only API, not a real browser API) and calls the Anthropic API directly with no key, because Claude.ai authenticates that transparently inside its own environment.

`supabase/schema.sql` is a real, independently verified schema — 21 tables, 6 functions, 24 RLS policies, 5 masking views — deployed and confirmed working on its own Supabase project.

These two are not connected. The app does not talk to Supabase yet. If you're asked to "add a feature," check first whether it belongs in the current local-storage prototype or waits for the Supabase migration — don't build against a backend that isn't wired up.

The "Organization / Roles" feature in the current app is an explicitly labeled concept preview: shared PINs per role, not real per-person accounts. Don't describe it as real security in any docs or UI copy. It becomes real once Supabase Auth replaces it — not before.

Never write "done," "fully working," or "production-ready" language about a feature that hasn't actually been run and verified. This project has a specific history of features looking correct and having real bugs underneath — see below.

## Real incidents from this project's history — don't repeat them

A destructive SQL script was nearly run against the wrong Supabase project. Two projects existed under confusingly similar names; one was assumed empty based on what had been discussed, not what had been verified, and turned out to already be running a different, unrelated app. Always verify a target environment's actual state with a real read-only query before running anything destructive against it — never infer it from conversation history alone.

A raw database password was pasted into a chat conversation. Chat history is not a secrets store. If a credential like this is ever generated during a session, tell the user to rotate it and store it outside the conversation — don't just acknowledge and move on.

A temporal-dead-zone bug crashed the entire app on load (a variable used before its declaration further down the same function). It compiled fine — Babel/JS compilation does not catch this class of bug. It was only caught by checking actual declaration line numbers against usage, not by assuming a clean compile meant working code.

Real data-leak bugs were found in the role-masking system — a dashboard alerts panel and a CSV export both showed exact financial figures to roles that were supposed to have them hidden, because the masking was implemented in the main display but not in every place the same data was rendered. When adding a new place that shows financial data (fabric cost, customer outstanding, supplier payables, agent commissions), check whether the current role's hideMargins / hideOutstanding flags need to apply there too — don't assume the existing masking covers a new surface automatically.

Column-level security on the Supabase side is enforced via masking views (`fabrics_view`, `wholesale_customers_view`, etc.), not raw table grants — Postgres RLS protects rows, not individual columns. If a restricted role needs to see a table but not one sensitive column in it, query the `_view` version, not the base table.

## Engineering discipline established on this project

Test logic changes with real execution, not just by reading the code. Throughout this build, Node scripts were used to simulate business logic (tax splits, FIFO stock deduction, role-based masking, search filtering) with realistic data before trusting it. A change that "looks right" and a change that's been run against test cases are treated as different confidence levels — say which one you're giving.

Every change to the main app file should be followed by: a compile check, a check that every `t.xxx` translation reference has a matching definition, a check that every translation array is exactly 10 entries (see i18n below), a check for duplicate keys, and — for anything touching core money/stock logic — a check that the seed data and tax math still reconcile.

Changes should be additive wherever possible. Don't refactor or "clean up" working, unrelated code while adding a new feature.

If something can't be verified from this environment (a live browser render, an actual network call, a real user's click), say so plainly rather than implying it was tested. This project's AI features (ARA, dashboard insights) failed in the live environment multiple times in ways that never reproduced in static code review — the honest answer each time was "the code checks out, I can't reproduce this without a real browser," not a confident guess.

## i18n conventions

The app supports 10 languages via a `STRINGS` object: en, hi, gu, mr, ta, te, kn, pa, bn, hi-en (Hinglish — Latin-script code-mixed Hindi, written the way Indian traders actually text). Every entry is an array of exactly 10 strings in that fixed order. If you add a new user-facing string, it needs all 10 translations, in order, before it's usable — a 9-entry or 11-entry array is a bug, not a style issue.

## Domain logic worth knowing before touching it

GST: CGST+SGST when buyer and seller are in the same state, IGST when they're not. Get this backwards and every invoice is wrong.

Stock deduction is FIFO by lot — oldest lot depleted first.

Wholesale customer aging buckets are 0-30 / 30-60 / 60-90 / 90+ days, computed from unpaid order age, payments applied FIFO across orders.

Role hierarchy (current prototype, and mirrored in `role_definitions` seed data): Default User (full access) down through General Manager, Sales Manager, Warehouse Manager, Accountant, Retail Supervisor, Wholesale Rep, Counter Staff, Godown Keeper, Dispatch Coordinator — each with its own tab access and margin/outstanding visibility. Changing one role's permissions should be deliberate, not incidental to an unrelated change.

## Roadmap (see README.md for the full list)

In short: migration importer, Vite restructuring, real Supabase-backed persistence, real Supabase Auth replacing the PIN system, real-time multi-device sync, a bring-your-own Anthropic API key field for AI features outside Claude.ai, and a real Vitest test suite. None of these are done. Don't assume any of them are in progress unless the repo's actual state shows it.

In short: migration importer, Vite restructuring, real Supabase-backed persistence, real Supabase Auth replacing the PIN system, real-time multi-device sync, a bring-your-own Anthropic API key field for AI features outside Claude.ai, and a real Vitest test suite. None of these are done. Don't assume any of them are in progress unless the repo's actual state shows it.
