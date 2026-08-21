# 11 — Mandatory Legal / Compliance Gates

This checklist intentionally prevents accidental launch into a regulated use case.

## Gate A — Paid organization plans

Before taking money:
- [ ] business/tax structure confirmed with commercialista;
- [ ] Terms for organization service;
- [ ] DPA;
- [ ] privacy roles documented;
- [ ] subprocessor list;
- [ ] refund/cancellation/renewal terms;
- [ ] Italian e-invoice/SdI workflow approved;
- [ ] EU VAT/customer-status workflow approved;
- [ ] Stripe production account/webhooks;
- [ ] mobile store payment policy reviewed for shipped UI.

## Gate B — Sessions with potentially sensitive questions

Before allowing Article 9-type Sessions:
- [ ] legal-basis responsibility contractually assigned to customer;
- [ ] participant notice;
- [ ] aggregate/private defaults;
- [ ] retention;
- [ ] no raw response analytics;
- [ ] DPIA decision recorded;
- [ ] employee-specific restrictions if workforce involved.

## Gate C — Employee use

Before named/trackable employee voting:
- [ ] employment/privacy counsel review;
- [ ] Article 4 Statuto dei Lavoratori implications assessed;
- [ ] legal basis not assumed to be consent;
- [ ] monitoring/profiling prohibited by default;
- [ ] DPIA where required.

Recommended product policy: keep employee Sessions anonymous/aggregate.

## Gate D — Persona L1 phone

Before SMS:
- [ ] Privacy + Google Play Data Safety updated;
- [ ] SMS processor/provider contract;
- [ ] rate limits;
- [ ] CAPTCHA;
- [ ] spend cap;
- [ ] phone HMAC secret;
- [ ] recycle/reclaim procedure;
- [ ] stale `phone_change` strategy if Supabase phone-update flow used.

## Gate E — Persona L2

Before document/selfie:
- [ ] DPIA completed;
- [ ] provider DPA/roles/transfers reviewed;
- [ ] legal basis documented;
- [ ] biometric alternative or justification;
- [ ] user notice;
- [ ] provider retention/redaction schedule;
- [ ] Social Vote minimal evidence fields finalized;
- [ ] deletion request workflow tested;
- [ ] staff-access audit;
- [ ] Data Safety/Privacy/Terms updated.

## Gate F — Organization verification

Before public verified badge:
- [ ] registry adapters/manual checklist;
- [ ] representative authority method;
- [ ] owner transfer;
- [ ] re-verification cadence;
- [ ] evidence retention;
- [ ] verification independent from paid plan.

## Gate G — Legally relevant/statutory voting

**BLOCKED for Sessions V1.**

Italian Third Sector law now permits, unless expressly prohibited by statute/constitutive act,
association participation by telecommunications and electronic voting when participant/voter identity
can be verified and good-faith/equal-treatment requirements are met.

That does not automatically make any generic QR poll legally sufficient.

Before Social Vote markets legal/statutory voting:
- [ ] entity/statute-specific legal opinion;
- [ ] identity/eligibility verification;
- [ ] membership cut-off/roster;
- [ ] quorum;
- [ ] proxies/delegations;
- [ ] weighted votes if statute requires;
- [ ] secret/open ballot rules;
- [ ] evidence/audit;
- [ ] challenge/recount procedure;
- [ ] retention/minutes;
- [ ] cryptographic/privacy review;
- [ ] product renamed/segmented as Governance.

## Gate H — Public institutions

Before municipality/public-body paid deployment:
- [ ] procurement/vendor requirements;
- [ ] DPA/security annex;
- [ ] FatturaPA/IPA/CIG/CUP requirements where applicable;
- [ ] accessibility requirements;
- [ ] public-record retention requirements;
- [ ] public authority legal basis.
