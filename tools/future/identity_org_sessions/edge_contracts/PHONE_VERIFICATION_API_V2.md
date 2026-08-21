# Phone Verification API V2 — Future Contract

No deployment until Phase 4 gates pass.

## POST /identity/phone/start

Auth: authenticated Social Vote user.

Input:
```json
{"phone":"+39...","captchaToken":"..."}
```

Server:
1. validate authenticated user/account status;
2. normalize phone to E.164;
3. compute server-only phone HMAC;
4. check active/released/blocked claim;
5. enforce per-IP/user/HMAC limits;
6. create provider challenge;
7. return opaque challenge ID.

Never return/store OTP.
Never log raw phone.

## POST /identity/phone/verify

Input:
```json
{"challengeId":"opaque","code":"123456"}
```

Atomic server operation:
1. verify provider OTP;
2. re-check phone HMAC conflict;
3. create active unique claim;
4. revoke old active claim for same user only through approved change flow;
5. write verification evidence;
6. mark L1 prerequisites complete;
7. audit result without raw number.

A race on the unique phone-HMAC constraint fails closed.

## POST /identity/phone/change/start

Requirements:
- strong reauthentication;
- current account not in restricted recovery state.

Do not release the old claim until new phone verification succeeds.

## POST /identity/phone/change/commit

Atomic:
- verify new challenge;
- create new claim;
- release old claim;
- set old reusable_after;
- update L1 evidence;
- audit.

## POST /identity/phone/reclaim

For recycled numbers.
Inputs:
- new verified OTP;
- account proof;
- optional L2/manual evidence.

Returns review case, never immediate takeover when number belongs to another active account.

## Admin/support

Only security/admin workflow can:
- block HMAC;
- approve reclaim;
- shorten/extend cooldown with reason;
- view masked phone metadata if raw number is stored by auth/provider.

All overrides audited.
