# Identity / Organization / Sessions — Security & Privacy Checklist

## Phone verification
- Normalize to E.164 server-side.
- OTP provider credentials only in server secrets.
- CAPTCHA / abuse protection before sending OTP in production.
- Per-IP, per-user and per-phone-hash rate limits.
- HMAC phone uniqueness with a server-only pepper.
- Never log raw phone numbers or OTP values.
- Never store OTP plaintext.
- Add reclaim process for recycled phone numbers.
- Update Privacy Policy and Google Play Data Safety before enabling collection.

## Level 2 identity documents
- Prefer hosted KYC/identity provider flow.
- Keep document images outside Social Vote when possible.
- Persist provider verification reference, status, timestamps and only strictly necessary extracted attributes.
- Explicit consent/notice before the verification begins.
- Define retention/deletion policy before production.
- Do not expose verification evidence to normal moderators unless necessary.
- Admin access must be audited.

## Organization verification
- Private evidence bucket if manual evidence is ever uploaded.
- Short retention after review unless a legal/security reason requires longer retention.
- Record the evidence type and review decision, not unnecessary document content.
- Re-verification path after representative changes.

## Sessions
- Session join endpoints must not require Social Vote accounts.
- Organizer control endpoints require authenticated verified-organization membership.
- Use cryptographically random access tokens; database stores token hashes only.
- Session codes are discoverability handles, not security credentials by themselves.
- Enforce one response per question per participant credential server-side.
- Separate organizer/audit data from ballot content.
- Do not claim one-person-one-vote for Open anonymous mode.
- Cascade-delete participant tokens and raw votes according to selected retention policy.
- No analytics/advertising identifiers are needed on the participant voting page.
