# 03 — Persona Identity L1 / L2 Specification

## Compatibility with CURRENT Social Vote

The reviewed CURRENT already defines:
- `VerificationLevel.none`
- `VerificationLevel.level1`
- `VerificationLevel.level2`
- request types `citizenLevel1`, `citizenLevel2`, `publicOfficial`, `institution`, `organization`
- public actor types citizen / publicOfficial / institution / organization
- a separate `votingCountryCode`

Do not replace these enums. Future work must extend the existing domain.

## Persona L1 — Account Integrity

L1 should mean:
1. Social Vote email/account is confirmed.
2. Possession of one mobile number has been proven by OTP.
3. That verified number has only one **active** Social Vote account claim.
4. Anti-abuse checks passed.
5. Any `votingCountryCode` is evaluated separately; never infer it from the telephone prefix.

L1 does **not** mean:
- legal identity proven;
- citizenship proven;
- residence proven;
- "one phone = one human";
- immunity from SIM swap.

### Phone uniqueness model

Input handling:
- accept raw number only at the verification endpoint;
- normalize server-side to E.164;
- compute `HMAC-SHA256(server_secret, normalized_phone)`;
- never expose secret or HMAC to Flutter;
- do not store raw phone in public application tables;
- never log OTP or raw number.

State:
- active
- released
- blocked
- reclaim_review

Constraints:
- one active claim per phone HMAC;
- one active phone claim per account;
- atomic claim after successful OTP;
- application-level rate limits per IP/user/phone-HMAC.

Release/reuse:
- initial recommended cooldown: 90 days after account deletion/release;
- manual reclaim path because operators recycle mobile numbers;
- strong re-authentication to change/release a verified number;
- sensitive voting privileges can be temporarily downgraded during number-change/reclaim review.

### Supabase implementation note

Do **not** make phone the stable primary account identifier. Supabase itself warns that mobile numbers
are recycled.

Preferred integration:
- keep email/current auth identity as primary;
- use phone verification as a second verification factor / evidence;
- enforce Social Vote uniqueness in its own server-side claim table.

If `auth.updateUser({phone})` is ever used, implement stale `phone_change` cleanup before production.
Supabase published a 2026 troubleshooting note explaining that abandoned duplicate `phone_change`
values can cause an OTP verification to affect the wrong auth record.

Production:
- CAPTCHA/Turnstile;
- provider/send rate limits;
- per-phone cooldowns;
- fraud/velocity controls;
- admin recovery with audit.

## Persona L2 — Government Identity

L2 should mean:
1. active L1;
2. government-issued ID verification;
3. holder/document match using a legally approved verification method;
4. successful provider result or audited manual alternative;
5. verification not expired/revoked.

### Provider abstraction

Do not hard-code the domain to Stripe. Store:
- provider key;
- opaque verification session/reference;
- status;
- document type category;
- issuing country;
- verification completed timestamp;
- expiry/reverify timestamp;
- over-18 result if needed;
- minimal failure category;
- evidence version.

Avoid storing:
- document image;
- selfie image;
- full ID number;
- MRZ;
- full extracted address;
- biometrics.

### Stripe Identity as first candidate

Current public facts:
- Italy is supported for selfie checks.
- Public price: €1.25 per successful document+selfie verification; first 50 free.
- Stripe warns that in the EU biometric use may require justification or a non-biometric alternative.
- Stripe allows VerificationSession redaction.
- Stripe advises not to place sensitive PII in session metadata.
- Stripe's current user-facing material says biometric identifiers are retained up to one year and
  other submitted identity information is normally stored for three years unless deleted sooner or a
  longer legal obligation applies.
- Stripe states it may act as an independent controller for some identity/fraud processing.

Therefore before live L2:
- perform DPIA;
- review international-transfer/subprocessor terms;
- update Social Vote privacy;
- choose default redaction timing;
- provide a non-biometric/manual or national-eID alternative where required;
- never download/copy document images unless strictly necessary;
- if images must be accessed, use short-lived provider links.

### Recommended Social Vote retention

After successful provider verification:
- Social Vote database: keep minimal outcome/evidence until account deletion or scheduled
  re-verification + limited dispute/security period.
- Provider raw session: redact as soon as the defined verification/dispute purpose permits; do not
  blindly accept a provider's maximum/default retention.
- failed/abandoned sessions: short retention, e.g. 7–30 days, unless fraud investigation requires
  longer.
- raw manual document uploads, if ever used: private encrypted bucket and delete quickly after review.

Exact periods require legal approval and must be reflected in Privacy Policy.

## Reverification

Trigger when:
- L2 expires according to policy;
- material identity change;
- credible impersonation report;
- account recovery after high-risk takeover;
- provider revokes/invalidates evidence.

Do not require routine document re-upload more often than necessary.

## Voting country

Keep the existing separation:
- profile residence = editable;
- phone country prefix = not proof;
- document issuing country/nationality = evidence, not automatically voting entitlement;
- `votingCountryCode` = separately approved product attribute.
