# Social Vote — Identity L2, Verified Organizations, and Sessions

Status: PRODUCT/TECHNICAL FOUNDATION ONLY — OFF. Do not deploy before the current Web/Admin and Android RC are frozen.

## 1. Identity model

Existing invariant stays unchanged:
- Persona uses verification levels `none`, `level1`, `level2`.
- Public Official, Public Institution and Verified Organization are separate public identity types and do not use Persona Level 1/Level 2.
- Technical roles `user`, `moderator`, `admin` remain independent from public identity.

### Persona Level 1
Recommended future meaning:
1. Email confirmed.
2. Mobile phone possession verified by OTP.
3. The verified phone number is actively claimed by no other Social Vote account.
4. Verification country is recorded separately from editable profile residence.

Level 1 is an anti-abuse / account-integrity signal. It does NOT prove that a phone number uniquely identifies one human being.

### Persona Level 2
Recommended future meaning:
1. All Level 1 requirements.
2. Government-issued identity document verification.
3. If the chosen provider supports it, liveness/selfie matching as part of the provider-hosted verification flow.
4. Social Vote stores the minimum verification outcome/reference needed to prove the check, not raw document images where avoidable.

Phone-only must not be called Level 2.

## 2. One phone number / one active account

Use a server-side deterministic HMAC of the normalized E.164 number. Never expose the HMAC secret to Flutter.

Rules:
- one active phone claim per user;
- one active user per phone HMAC;
- no raw phone number in public application tables;
- the raw number is sent only to the OTP provider when needed;
- after account deletion or number release, retain only the pseudonymous HMAC for a configurable abuse-prevention cooldown, then allow reuse;
- support a manual reclaim path because mobile numbers are recycled by carriers.

Recommended cooldown for the first pilot: 90 days after release/deletion, with admin override after strong re-verification.

## 3. Verified Organization

Verification itself is not sold as a badge. Payment buys professional tools, not credibility.

Minimum verification evidence:
- legal/public organization name;
- organization type;
- country;
- official registry reference when one exists;
- website or official public page when available;
- requester name and role;
- requester verified phone;
- proof that the requester can represent the organization: institutional-domain email OR signed delegation / official appointment evidence;
- if registry verification is insufficient: constitution/statute, incorporation/registration certificate, or equivalent official evidence.

For Italy, support optional references such as RUNTS / Registro Imprese / another competent public register, without requiring a register that does not apply to the organization.

Do not request documents that are not necessary for the decision.

## 4. Social Vote Sessions

Working product name: `Social Vote Sessions`.

Purpose: verified organizations can run live polls during meetings, assemblies, staff sessions, workshops and events. Participants can vote from a browser without creating a Social Vote account.

### Session flow
1. Organizer creates a Session.
2. Adds Yes/No, One answer, or Multiple answers questions.
3. Chooses participant access mode and result visibility.
4. Opens the session.
5. Participants scan a QR code or enter a short session code.
6. Questions can be opened/closed live.
7. Results can be shown live, after each vote, after closing, or only to the organizer.
8. At the end the organizer archives, exports, or deletes the session.

### Access modes

#### A. Open anonymous
- no Social Vote account;
- join by public session code/link;
- lightweight browser/device duplicate protection only;
- MUST display `basic anti-duplicate protection` because one-person-one-vote cannot be guaranteed.

#### B. Controlled anonymous — recommended for meetings
- organizer generates N one-time participant access tokens / QR codes;
- each token grants one anonymous participant credential;
- one vote per question per participant credential;
- participant still creates no Social Vote account;
- organizer can know which tokens were distributed, but the default results view must not reveal how a named person voted.

#### C. Roster mode — future
- organization imports employee/member identifiers and distributes individual invite tokens;
- no Social Vote account required;
- introduces additional personal-data obligations and therefore stays out of V1.

### V1 question types
- Yes / No
- One answer
- Multiple answers

Do not expose Ranked / Score / Approval until the voting UX truly supports those models.

### Results/retention
Organizer chooses one policy before opening:
- Ephemeral: delete question-level votes automatically after 24 hours.
- Short archive: 7 days.
- Standard archive: 30 days.
- Organization archive: retained until organizer deletes it, subject to plan/retention rules.

An optional aggregate-only snapshot may be retained only when the organizer explicitly chooses it.

### Not legally binding by default
Social Vote Sessions is a participation and consultation tool. It must not claim that a session is a legally binding election, statutory assembly vote, works-council vote, shareholder vote, referendum, or other legally regulated ballot unless a separate legal/compliance product has been designed for that use case.

## 5. Revenue principle

Revenue comes from organization tooling:
- live sessions;
- larger participant limits;
- multiple organizers;
- exports and archive;
- custom branding;
- reporting;
- API/webhooks later;
- support.

Never sell:
- extra voting weight;
- artificial ranking or reach;
- verification approval;
- a public badge without completing the same verification rules.
