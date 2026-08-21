# 09 — Implementation Phases

Do not mix this work into the release currently being frozen.

## Phase 0 — Current release
- finish Admin/Web IT/EN/DE runtime;
- new Android RC;
- real-device PASS;
- checkpoint ZIP.

No paid/identity deployment.

## Phase 1 — Organization entity foundation
Build:
- organization entity;
- memberships/operators;
- registry evidence;
- owner transfer;
- verification Admin workflow;
- public minimal organization view.

No billing yet.

Exit gate:
- fake org cannot self-mark verified;
- representative change works;
- Admin audit works;
- no sensitive evidence leaks.

## Phase 2 — Sessions MVP, free pilot
Build:
- workspace;
- Session lifecycle;
- questions/options;
- open anonymous;
- controlled anonymous token pool;
- presenter page;
- participant web page;
- result policies;
- retention jobs;
- aggregate export.

No card payment yet.

Pilot:
- 5–10 Merano organizations;
- 90 days;
- two real Sessions each where possible.

Exit gate:
- repeat usage;
- privacy model works;
- support burden known;
- at least 3 organizations state willingness to pay.

## Phase 3 — Billing
Only after product proof.

Build:
- Stripe Checkout/Billing server integration;
- webhook;
- billing account;
- entitlements;
- invoices/accounting integration;
- customer portal;
- tax profile.

Launch:
- Starter;
- Pro;
- Team;
- Event passes;
- setup review.

## Phase 4 — Persona L1
Separate security release:
- SMS provider;
- phone claims;
- OTP;
- reclaim;
- rate limits/CAPTCHA;
- Privacy/Data Safety update.

Do not tie launch of Sessions to L1 because participants do not need accounts.

## Phase 5 — Persona L2
Only after DPIA/legal/provider review:
- provider abstraction;
- Stripe Identity or selected provider;
- manual/non-biometric alternative;
- minimal evidence;
- redaction/deletion;
- Admin review.

## Phase 6 — Social Vote Consultations
- campaign pages;
- multilingual questionnaires;
- geographic context;
- aggregate reports;
- no paid civic-feed ranking.

## Phase 7 — Social Vote Governance
Separate product/security/legal project.

Required before statutory/legal claims:
- eligibility/member roster;
- participant identity;
- quorum;
- proxies/delegations;
- weighted rights where applicable;
- open vs secret ballot;
- stronger ballot unlinkability;
- tamper-evident audit;
- meeting-minute evidence;
- independent verification/scrutineer model;
- statute configuration;
- legal review by entity type/country;
- incident/recount/challenge procedure.

Do not retrofit these requirements casually into Sessions V1.
