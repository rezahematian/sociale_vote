# 00 — Executive Decision

## Commercial thesis

Social Vote should remain free for ordinary civic participation and monetize **professional
organization workflows**. The commercial product is not "pay to be trusted"; it is software that
saves organizations time, reduces meeting friction, produces clear aggregate evidence, and connects
private deliberation to an optional public civic presence.

### The value ladder

**Free civic layer**
- verified public organization identity;
- official public profile;
- normal Social Vote Post/Poll publication;
- normal civic visibility under the same ranking/visibility rules as everyone else;
- no paid vote weight, no paid moderation privilege, no paid political reach.

**Paid operations layer**
- organization workspace with multiple operators;
- Social Vote Sessions;
- controlled anonymous token pools;
- session agenda and question control;
- result visibility rules;
- CSV/PDF aggregate reports;
- retention/archive controls;
- organization branding on its own session page;
- priority support;
- later SSO/API/webhooks.

**Paid service layer**
- setup review;
- managed event;
- onboarding/training;
- later public-consultation campaign setup.

## First product to sell

**Social Vote Sessions**.

Use case:
1. The chair/manager creates a meeting.
2. Questions are prepared before or during the meeting.
3. A QR/join code is projected.
4. Participants vote in a browser without Social Vote registration.
5. The organizer can use open anonymous access for informal questions or a pre-generated anonymous
   token pool when one credential per participant is required.
6. Results appear live, after each vote, after close, or organizer-only.
7. Data can disappear automatically or be archived/exported according to policy.
8. An aggregate result can optionally be published into Social Vote later, without publishing
   participant credentials.

This is more defensible than being another generic survey tool because Social Vote can combine:
- a verified organization identity;
- private meeting participation;
- public civic communication;
- multilingual IT/DE/EN;
- geographic/civic context;
- privacy-preserving participation.

## What must never be monetized

- verification approval;
- Persona L1/L2 approval;
- the public badge itself;
- voting power;
- the right to create a vote that ordinary users could otherwise create;
- favorable moderation outcomes;
- user private data;
- artificial feed ranking/reach for political/civic content;
- access to individual secret ballot choices.

## Product naming

Recommended:
- **Social Vote Organizations** — verified entity + workspace.
- **Social Vote Sessions** — live/private meeting voting.
- **Social Vote Consultations** — later public consultation campaigns.
- **Social Vote Governance** — future, separately engineered, legally reviewed voting product.

Avoid marketing Sessions V1 as:
- "certified election";
- "legally valid assembly voting";
- "guaranteed one person one vote";
- "fully anonymous" unless the technical mode and legal wording support that claim.
