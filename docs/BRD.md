# Bolt & Bahi — Business Requirements Document

## Business objective

Replace the paper-bahi-and-WhatsApp workflow that Indian fabric traders currently use to run billing, stock, and dispatch with a single ledger app — reducing GST invoicing errors, missed reorders, and untracked receivables.

## Background

Fabric traders typically bill customers, track stock, and manage dispatch across paper registers, WhatsApp messages, and disconnected spreadsheets. GST is split into CGST/SGST or IGST by hand on every invoice, and supplier payables and customer aging are tracked from memory. This creates recurring, avoidable losses: invoicing mistakes, fabric that isn't reordered until it's already out of stock, and receivables that go uncollected simply because no one is tracking due dates.

## Scope

In scope: fabric register and stock, retail counter billing, wholesale ordering with price slabs, job work tracking, dispatch and logistics, GST-correct invoicing, receivables and payables, the ARA assistant, and multi-language/multi-theme support.

Out of scope: multi-device sync, real individual staff logins, and payment processing — all planned for a later phase once the app is connected to the verified Supabase schema.

## Stakeholders

- Primary user: fabric trader (retail counter or wholesale distributor)
- End user: job-work units and customers interacting indirectly through invoices and dispatch
- Product owner: Pryank Wadhera

## Go-to-market model

Currently a free, local-first web app with no account or subscription required to use — the trader's own Anthropic API key powers the optional ARA features (bring-your-own-key, nothing billed to anyone but the trader). No pricing model is defined yet; that decision follows the next phase of work, once the app is connected to real accounts via the verified Supabase schema.

## Success criteria

- Reduction in GST invoicing errors compared to manual calculation
- Reduction in fabric stockouts caught only after a customer order fails
- Reduction in receivables left uncollected past their due date

## Assumptions

- Traders are willing to move billing and stock tracking off paper and WhatsApp onto a browser-based app
- Traders who want AI features are willing to create their own Anthropic API key

## Risks

- Adoption risk: traders accustomed to paper bahis may need hands-on onboarding to switch
- Data risk: since data is local-first, a lost or reset browser/device means lost data until the Supabase-backed sync phase ships

## Status

Live demo/prototype stage — v1 is built and deployed at pryank18.github.io/bolt-and-bahi/, running on browser localStorage. No production billing or account system yet; a verified Supabase schema exists in /supabase for that next phase.
