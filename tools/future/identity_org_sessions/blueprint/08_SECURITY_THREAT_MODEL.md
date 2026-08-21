# 08 — Security / Abuse Threat Model

## Phone/L1 threats

### SMS pumping / cost abuse
Controls:
- CAPTCHA;
- per-IP/user/HMAC limits;
- send cooldown;
- country allowlist during pilot;
- daily spend cap/provider alert;
- no unlimited resend UI.

### Recycled phone
Controls:
- phone not primary account identity;
- 90-day released-claim cooldown;
- reclaim workflow;
- strong reauth;
- no automatic account takeover based on phone possession alone.

### SIM swap
Controls:
- L1 is not L2;
- sensitive account recovery cannot rely only on SMS;
- optional TOTP/passkey later;
- L2/organization ownership transfer needs stronger evidence.

### Race for same number
Controls:
- atomic DB unique partial index on active HMAC;
- OTP verified before claim;
- server transaction.

## L2 threats

### Document theft / spoofing
- hosted provider;
- document authenticity;
- optional selfie/liveness only after legal gate;
- provider risk result;
- manual escalation.

### Sensitive data leakage
- no raw images copied into Social Vote by default;
- no PII in provider metadata;
- short-lived links only;
- restricted staff access;
- audited access;
- redaction workflow.

### Vendor lock-in
- provider-neutral evidence table;
- provider reference separate from public verification status.

## Organization threats

### Fake association
- registry-first verification;
- public registry match;
- domain/PEC or documentary authority.

### Rogue employee claims organization
- entity existence check + representative authority check;
- owner transfer audit;
- reverify on representative change.

### Purchased badge
Prevent structurally:
- billing tables cannot set verification status;
- verification approval endpoint does not inspect plan;
- paid support never guarantees approval.

## Sessions threats

### Guessable join code
Join code is discovery only.
Controlled mode requires cryptographic token.

### Token theft/sharing
- high-entropy tokens;
- optional visual one-time distribution;
- token revoke/reissue before vote;
- one use per question;
- short Session validity.

### Duplicate vote race
- one server transaction;
- unique `(question_id, token_id)` token-use constraint;
- ballot insertion only if token-use insert succeeds.

### Organizer re-identification
- no token ID on ballot row;
- no exact vote timestamp export;
- no participant response history;
- no IP/device data in organizer API;
- aggregate-only export;
- subgroup suppression.

### Malicious organizer
- participant notice states organization is controller;
- fixed privacy/result mode after opening;
- immutable audit of organizer setting changes;
- sensitive setting changes blocked after first ballot.

### Insider/database-admin correlation
V1 does not claim cryptographic anonymity against a privileged platform operator.
Future Governance/strong-anonymity mode requires separate credential and ballot domains and
destructible/cryptographic unlinkability.

## Billing threats

- Stripe webhook signature verification;
- idempotency by provider event ID;
- no client-side plan activation;
- entitlement checks server-side;
- price/plan mapping server-owned;
- no amount supplied by client as authority.

## Audit strategy

Audit:
- verification reviews;
- organization ownership;
- Session open/close/config changes;
- token batch generation/revocation;
- exports;
- billing entitlement changes;
- admin overrides.

Do **not** audit secret ballot choice content.
