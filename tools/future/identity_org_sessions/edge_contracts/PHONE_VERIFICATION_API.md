# Future Edge Function contracts — Phone Verification

Do not implement/deploy before SMS provider selection and privacy update.

## POST /phone-verification/start
Authenticated user only.
Input: `{ phone: "+39..." }`
Server:
- normalize E.164;
- apply CAPTCHA/rate limits;
- compute HMAC(phone) using server-only secret;
- reject if another active user owns the HMAC;
- ask OTP provider to send code;
- return opaque challenge id, never OTP/provider secrets.

## POST /phone-verification/verify
Authenticated user only.
Input: `{ challengeId, code }`
Server:
- validate provider challenge;
- atomically create/update active phone claim;
- reject races on unique phone HMAC;
- write `phone_otp` verification evidence;
- update the verification request prerequisites, but do not grant Level 2 automatically.

## POST /phone-verification/release
Strong re-authentication required.
- release current phone claim;
- set `reusable_after` according to abuse-prevention policy;
- invalidate any verification state that requires an active verified phone.
