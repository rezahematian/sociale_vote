# Organization Billing API — Future Contract

## POST /billing/checkout

Auth:
- organization owner/billing manager.

Input:
```json
{"organizationId":"uuid","plan":"starter","billingPeriod":"annual"}
```

Server:
- confirm organization verified/eligible;
- resolve trusted server-side price ID;
- create/reuse Stripe Customer;
- create Checkout Session;
- return provider URL.

Client never supplies authoritative price/amount.

## POST /billing/webhook

Public provider endpoint with signature verification.

Handle idempotently:
- checkout.session.completed
- customer.subscription.created/updated/deleted
- invoice.paid
- invoice.payment_failed
- relevant dispute/refund events

Write:
- billing event ledger;
- normalized subscription;
- entitlements.

## GET /organizations/{id}/entitlements

Authenticated organization member.
Returns normalized features/limits, never Stripe secrets.

## POST /billing/customer-portal

Owner/billing manager.
Returns short-lived portal URL.

## Authorization rule

All paid product operations validate server-side entitlements.
Flutter/UI visibility is not enforcement.

## Tax profile

Collect separately:
- legal name
- address
- country
- CF
- P.IVA/VAT ID
- PEC/codice destinatario if Italy
- customer tax classification

Do not infer tax treatment from organization verification alone.
