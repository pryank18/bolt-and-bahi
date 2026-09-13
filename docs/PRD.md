# Bolt & Bahi — Product Requirements Document

## Summary

Bolt & Bahi gives Indian fabric traders a single ledger for stock, retail and wholesale billing, job work, dispatch, and receivables/payables, with GST-correct invoicing built in, replacing paper bahis, WhatsApp threads, and disconnected spreadsheets.

## Target users

- Retail counter owner — sells fabric directly to walk-in customers and needs fast, GST-correct billing
- Wholesale distributor — sells in bulk to other businesses using price slabs and MOQs, and tracks credit and dispatch

## Problem statement

Traders run billing, stock, and dispatch across paper registers and WhatsApp, calculate GST splits (CGST/SGST vs IGST) by hand, and track supplier payables and customer aging from memory rather than a system. This leads to invoicing errors, missed reorders, and receivables that go unnoticed until they're seriously overdue.

## Functional requirements

- Fabric register — roll/lot-level stock with GSM, width, cost, and pricing
- Retail billing — counter sales with automatic GST calculation
- Wholesale ordering — price slabs, MOQ enforcement, and order tracking
- Job work tracking — fabric sent to and received back from job-work units
- Dispatch and logistics — partial dispatch and transport tracking
- Receivables and payables — customer aging and supplier dues in one place
- ARA assistant — bring-your-own-key Anthropic integration for reminders, day summaries, and photo-to-stock entry
- Localization — ten languages (including Hinglish) and five visual themes

## Out of scope (v1)

- Multi-device sync or cloud accounts (data is local-first, single device)
- Real individual staff logins (current roles are shared PINs, not per-user auth)
- Payment gateway integration

## Success metrics

- Reduction in GST invoicing errors versus manual calculation
- Reduction in time spent reconciling stock, sales, and dispatch across separate records
- Reduction in receivables left untracked past their due date

## Status

Live at pryank18.github.io/bolt-and-bahi/, running on browser localStorage with bring-your-own-key Anthropic integration for ARA. A verified Supabase schema (21 tables, 24 RLS policies) exists in /supabase for the next phase of work but is not yet wired into the live app.
