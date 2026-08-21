# 06 — Privacy / GDPR / DPA Model

This is a product-engineering blueprint, not legal advice. Obtain qualified privacy/legal review
before activation.

## GDPR principles that drive the design

The EU GDPR requires purpose limitation, data minimization, storage limitation and appropriate
security. Sessions must be designed so that collecting less data is the default, not an optional
afterthought.

## Special-category risk

Poll answers can reveal:
- political opinions;
- religious/philosophical beliefs;
- trade-union membership;
- health;
- sexual life/orientation.

These can fall under GDPR Article 9 special categories. The fact that the UI calls something a
"poll" does not remove that classification.

A nonprofit body's specific Article 9 route for members/regular contacts can apply in defined cases,
but Social Vote must not assume it is available for every customer or every Session.

## Controller / processor model

Recommended for B2B Sessions:

**Customer organization = controller** for:
- why the Session exists;
- questions;
- invited/eligible population;
- legal basis;
- result use;
- retention selection within allowed product bounds.

**Social Vote = processor** for Session voting data, acting on documented customer instructions.

**Social Vote = independent controller** for:
- organization account administration;
- billing;
- fraud/security;
- its own legal obligations;
- verification of the Social Vote organization profile.

Do not reuse raw Session ballots for Social Vote product analytics/AI/training. Doing so can change
the role analysis and undermine the processor model.

## DPA required before paid B2B launch

The customer agreement/DPA should cover at least:
- subject and duration;
- nature/purpose;
- data categories/data subjects;
- documented instructions;
- confidentiality;
- technical/organizational security;
- subprocessors;
- assistance with data-subject rights;
- breach cooperation;
- deletion/return;
- audits/information;
- international transfers.

Maintain an up-to-date subprocessor list.

## Data residency / transfers

Before B2B launch:
- verify the actual Supabase project region;
- document Firebase/hosting and other subprocessors used by participant pages;
- document SMS/email providers;
- document Stripe if used;
- determine transfer mechanism for data leaving the EEA.

Stripe currently states that Identity verification data may be processed/stored in the United States.
That is a material L2 privacy gate and must be reflected in the DPIA/notice/provider review.

## DPIA gates

Run a DPIA before:
- Persona L2 biometric/document verification;
- systematic high-risk anti-fraud profiling;
- Sessions likely to collect Article 9 data at meaningful scale;
- employee monitoring or identifiable employee response tracking;
- governance-grade voting;
- public-body deployments with sensitive data.

Italian Garante guidance identifies systematic monitoring and sensitive/highly personal data as
high-risk criteria.

## Employee Sessions

Default employee mode must be:
- controlled anonymous token pool;
- no identity-response mapping;
- no response-level history;
- no productivity/behavior scoring;
- no advertising analytics;
- aggregate results only.

Do not assume employee consent is freely given. Italian Garante decisions repeatedly emphasize the
power imbalance in employment and the interaction with Article 4 of the Workers' Statute where
technological systems can monitor work activity.

If an employer wants named response tracking, stop and require legal/privacy review.

## Participant notice

Accountless participant page should show a concise notice before joining:
- organization running the Session;
- purpose;
- whether response is anonymous to organizer;
- access mode;
- what data Social Vote stores;
- result visibility;
- raw retention period;
- link to full privacy notice;
- contact for rights;
- warning if question may contain sensitive data, where appropriate.

## Data subject rights

Provide controller workflow for:
- access where applicable;
- correction of roster data;
- deletion/restriction when legally applicable;
- objection;
- provider deletion/redaction for identity data.

Secret/anonymous ballots require careful response: if a ballot is intentionally no longer linkable to
a person, Social Vote may be technically unable to identify a specific ballot for access/deletion.
This must be explained before collection, not discovered later.

## Security baseline

- TLS only;
- server-side authorization;
- RLS plus protected functions;
- secrets in server secret store only;
- audit organizer/admin actions;
- no raw OTP logs;
- no raw document images in Social Vote if avoidable;
- token hashes, not plaintext;
- cryptographic random credentials;
- rate limiting;
- CAPTCHA on abuse-prone public endpoints;
- encrypted backups;
- documented deletion jobs;
- breach-response runbook.
