# Bolt & Bahi — Product Spec

## Problem

Indian fabric traders — retail counters, wholesale distributors, and job-work units — run billing, stock, and dispatch across paper bahis, WhatsApp, and disconnected spreadsheets. GST invoicing (CGST/SGST vs IGST) is calculated by hand, supplier payables and customer aging live in memory or notebooks, and there is no single place to see stock, sales, and dispatch at a glance.

## Target user

Indian textile traders running retail counter billing, wholesale distribution, and job work — typically without an accounting background or budget for enterprise ERP software.

## Goals

- Give traders one ledger for stock, retail and wholesale billing, job work, dispatch, and receivables/payables
- Calculate GST correctly (CGST/SGST vs IGST) automatically on every invoice
- Work in the trader's own language (ten languages, including Hinglish) and preferred visual theme
- Let ARA, a built-in assistant, draft reminders, summarize the day, and read a fabric photo straight into stock, using the trader's own Anthropic API key

## Non-goals (v1)

- Multi-device sync or cloud accounts — data is local-first, single device (browser localStorage)
- Real individual staff logins — today's roles are shared PINs per role, not per-user authentication
- Payment processing

## Core features (v1 scope)

- Fabric register — roll/lot-level stock with GSM, width, cost and retail/wholesale pricing
- Retail billing — counter sales with GST-correct invoicing
- Wholesale distribution — price slabs, MOQ, and order tracking for distributors
- Job work tracking — track fabric sent out and received back from job-work units
- Dispatch and logistics — partial dispatch, transport tracking, delivery status
- Receivables and payables — customer aging and supplier payables in one register
- ARA assistant — bring-your-own-key Anthropic assistant for reminders, day summaries, and photo-to-stock entry
- Languages and themes — ten languages (incl. Hinglish) and five visual themes

## User stories

- As a trader, I want GST split correctly between CGST/SGST and IGST automatically, so I don't have to calculate it by hand on every invoice.
- As a trader, I want to see stock, today's sales, and pending dispatches on one dashboard, instead of checking three registers.
- As a trader, I want to ask ARA to draft a payment reminder or summarize the day, so I don't have to write it myself.
- As a job-work unit, I want fabric sent out and received back tracked against the same roll, so nothing gets lost between locations.

## Success metrics (hypothesis)

- Reduction in GST invoicing errors compared to manual calculation
- Reduction in time spent reconciling stock, sales, and dispatch across separate records
- Reduction in overdue receivables left untracked past their due date

## Status

Live — v1 is built and deployed at pryank18.github.io/bolt-and-bahi/, running on browser localStorage with a bring-your-own-key Anthropic integration for ARA. A verified Supabase schema (21 tables, 24 RLS policies) already exists in /supabase for a planned next phase — real accounts and multi-device sync — but the live app is not yet connected to it.
