# Social Vote — Implementation phases (OFF blueprint)

Status: design only. No item in this file is enabled by copying the foundation.

## Phase ID-0 — product/privacy lock
- Keep the current public identity invariant: Persona uses none/L1/L2; Public Official, Public Institution and Verified Organization use their own verified identity with Persona level `none`.
- Decide the SMS provider and country coverage.
- Decide the hosted identity-document provider.
- Update Privacy/Data Safety before collecting a phone number or identity evidence.
- Define evidence retention and a manual number-reclaim procedure.

## Phase ID-1 — verified mobile / Persona L1
- Authenticated email account stays the primary account identity.
- Add server-side phone verification endpoints.
- Normalize to E.164 server-side.
- Store only an HMAC claim in application tables; never expose the HMAC secret to Flutter.
- One active phone claim per account and one active account per phone claim.
- OTP challenge rate limits + CAPTCHA + abuse monitoring.
- A verified phone is an anti-abuse / possession signal, not proof of one human.
- Initial release/reclaim cooldown proposal: 90 days after voluntary release/account deletion, with audited manual override after strong proof.

## Phase ID-2 — Persona L2
- Requires active L1.
- Launch hosted identity verification (government ID + selfie/liveness when supported).
- Store provider reference/outcome/timestamps and minimal attributes only; avoid copying raw ID images into Social Vote.
- L2 is granted only by reviewed provider outcome / protected backend flow.
- Expiry/re-verification policy must be explicit.

## Phase ORG-1 — Verified Organization
- Request organization identity without changing the technical account role.
- Verify legal/public name and requester authority.
- Prefer public registry lookup when applicable; accept alternate evidence when a registry does not apply.
- Organization verification is free; payment never buys the badge.

## Phase SES-1 — Sessions pilot
- Verified Organization workspace.
- Browser participant route independent from Social Vote account creation.
- Yes/No, One answer, Multiple answers only.
- Open anonymous and Controlled anonymous access.
- Controlled anonymous uses one-time participant credentials; DB stores hashes only.
- Configurable results visibility and retention.
- V1 explicitly non-legally-binding.

## Phase SES-2 — Billing after pilot evidence
- Introduce plan enforcement only after usage metrics and support burden are known.
- Billing events must be server-authoritative and idempotent.
- Paid status never changes verification trust, voting weight, public ranking, moderation, or civic participation rights.

## Phase SES-3 — organization upgrades
Potential paid extensions after V1:
- reusable organization templates;
- agenda + question sequencing;
- multiple operators/presenters;
- QR presentation screen;
- PDF/CSV aggregate reports;
- custom branding;
- recurring meetings;
- API/webhooks;
- SSO/roster mode only after a separate privacy/security review.
