# SOCIAL VOTE — Revenue / Identity / Organizations / Sessions Blueprint V2

**Status:** FOUNDATION / PRODUCT DESIGN ONLY — OFF  
**Date:** 2026-08-21  
**Authoritative code snapshot reviewed:** `sociale_vote(20260821-113629).zip`

This package is intentionally **non-deploying**. It replaces only the future-design folder
`tools/future/identity_org_sessions` when the installer is run.

It does **not** modify:
- `lib/`
- `supabase/migration/`
- `supabase/functions/`
- Android/iOS/Web runtime
- Firebase
- `pubspec.yaml`
- Google Play versioning
- AI configuration

All SQL files are **design simulations** wrapped in `BEGIN ... ROLLBACK`; they are not production
migrations.

## Executive decisions

1. **Never sell trust.** Verification/badges, voting weight, feed ranking and moderation decisions are
   not commercial products.
2. **Sell workflow.** The first monetizable product is **Social Vote Sessions** for associations and
   organizations: accountless meeting polling, controlled anonymous participation, result management,
   exports, teams and support.
3. **Separate identities.** Persona L1/L2 remain distinct from Verified Organization / Institution /
   Public Official, matching the existing Social Vote model.
4. **Phone L1 is anti-abuse, not proof of a human identity.** One verified phone can claim only one
   active Social Vote account, but carriers recycle phone numbers.
5. **L2 is document identity verification.** Use a hosted identity provider, minimize stored data, and
   do not make L2 a profit center.
6. **Organizations are entities, not users.** A future organization entity has multiple human
   operators. This avoids coupling legal identity to one account.
7. **Sessions V1 is not a legally certified election platform.** It is designed first for meetings,
   consultations and non-binding decisions. A separate future Governance product is required before
   claiming statutory/legal vote validity.
8. **Web-first billing.** Sell B2B plans through the web portal first. Mobile apps consume already-held
   entitlements; mobile purchase/steering is withheld until store-policy review.
9. **Privacy is a product feature.** Controlled anonymous Sessions deliberately separate token use from
   ballot content. No voter-response history is exposed to organizers.
10. **Release first.** This blueprint remains OFF until the current Admin/Web/Android release is stable.

See `blueprint/00_EXECUTIVE_DECISION.md` for the full commercial strategy.
