# 07 — Billing, Tax, Invoicing and App-Store Policy

This is an implementation checklist, not tax/legal advice.

## Recommended billing architecture

**Initial sales channel: Web only.**

Flow:
1. verified organization creates billing profile;
2. organization selects plan on web;
3. server creates Stripe Checkout;
4. Stripe webhook is the only authority for paid state;
5. server writes normalized entitlement;
6. Flutter/Web reads entitlement but never grants it client-side;
7. cancellation/downgrade is enforced server-side.

Use:
- Stripe Checkout;
- Stripe Billing for subscriptions;
- one-time Checkout for Event Pass;
- Customer Portal later.

Never put Stripe secret keys in Flutter.

## Billing entity

Subscription belongs to `organization_entity_id`, not to a human user.

Store:
- provider;
- customer reference;
- subscription reference;
- plan;
- status;
- current period;
- cancel-at-period-end;
- payment grace state.

Do not store card data.

## Entitlement state

Use independent entitlement rows so product authorization is not tied directly to Stripe JSON.

Example entitlements:
- sessions.monthly_limit
- session.participant_limit
- workspace.operator_limit
- export.csv
- export.pdf
- branding
- archive.days
- concurrent_sessions
- priority_support
- api_access

Server verifies entitlement for every paid mutation.

## Delinquency

Recommended:
- `active`: normal;
- `past_due`: 7-day grace;
- `restricted`: creation of new Sessions disabled, existing data readable/exportable;
- `canceled`: paid features end at period end;
- do not delete organization/session data merely because payment failed.

## Stripe cost context

Current public Italian Stripe pricing reviewed:
- standard EEA cards: 1.5% + €0.25;
- Billing pay-as-you-go: 0.7% of Billing volume;
- invoices after one-off Checkout: 0.4% of transaction, capped by Stripe's current tariff.

Re-check pricing before launch.

## Italy — electronic invoicing

For an Italian taxable operator, electronic invoicing obligations and the Sistema di Interscambio
(SdI) must be handled correctly. Collect billing fields needed by the actual accounting workflow:
- legal name;
- billing address;
- codice fiscale;
- P.IVA when applicable;
- PEC or codice destinatario when applicable;
- country;
- VAT status.

Do not assume that a payment-provider receipt alone satisfies Italian fiscal invoicing.

Before launch, choose:
A. accounting/e-invoicing provider integrated with SdI; or
B. a verified Stripe/accounting integration that actually supports the required Italian fiscal flow.

Have a commercialista approve the workflow.

## Associations and VAT

An association can have different fiscal/VAT status from a normal company. Do not classify every
association as a VAT-registered business merely because it is an organization.

Checkout must distinguish:
- Italian VAT business;
- Italian entity with CF but no VAT position as applicable;
- EU VAT-registered business;
- EU customer without valid VAT number;
- non-EU.

Tax treatment must be reviewed with an accountant.

## EU cross-border

Current EU guidance:
- B2B services to a business in another EU country generally use customer-country reverse charge,
  subject to exceptions and valid customer status;
- electronic services to final consumers can be taxed in the customer's country and OSS can be
  relevant.

Because nonprofits/associations do not all have the same VAT status, do not infer tax treatment from
the plan name.

## Google Play

Google Play normally requires Play Billing for digital features/services sold inside a Play-distributed
app, including cloud/business productivity services. EEA alternative-billing programs exist but have
their own enrollment/rules/fees.

Safest V1:
- no purchase button inside Android;
- organization buys/manages subscription on the web;
- Android consumes existing entitlement;
- review current Play policy before adding any external payment link/steering.

## Apple

Apple has exceptions for enterprise services sold directly to organizations and for some free
stand-alone companion apps, but Social Vote is also a consumer/social application. Do not assume an
enterprise exception automatically covers the whole app.

Safest V1:
- web purchase;
- iOS app can use entitlement already purchased;
- no in-app checkout or external purchase CTA until App Review rule analysis for the shipped build.

## Public-sector sales

Municipalities/public bodies may require:
- procurement/vendor registration;
- CIG/CUP or purchase-order references;
- FatturaPA/IPA fields;
- different contractual/DPA security requirements.

Do not enable self-service public-sector checkout in V1. Use manual quote/onboarding.
