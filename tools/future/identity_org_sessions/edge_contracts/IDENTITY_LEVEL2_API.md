# Persona L2 API — Future Provider-Neutral Contract

## POST /identity/l2/start

Auth:
- authenticated;
- active L1;
- account not suspended;
- retry/risk limits.

Input:
```json
{"providerPreference":"auto","method":"document_selfie"}
```

Server:
- choose provider/configuration;
- create provider verification session;
- store opaque reference only;
- return hosted URL/client secret as provider requires;
- never return provider secret key.

## POST /identity/l2/webhook

Provider-authenticated webhook.

Server:
- verify signature;
- idempotency by provider event ID;
- retrieve minimum result;
- map into normalized evidence;
- do not download images by default;
- on success create/review L2 request;
- on failure persist only normalized reason required for UX/fraud;
- schedule provider redaction according to approved retention policy.

## POST /identity/l2/status

Returns only:
- pending / requires_input / under_review / verified / rejected / expired;
- generic reason;
- reverify date.

Never returns raw document data.

## POST /identity/l2/delete-provider-data

Authenticated deletion workflow:
- verify eligibility/legal hold;
- redact provider session;
- track asynchronous redaction completion;
- delete Social Vote evidence no longer required;
- explain independent provider-controller deletion path if applicable.

## Alternative verification

A non-biometric/manual/national-eID path must be representable by the same normalized evidence model.
