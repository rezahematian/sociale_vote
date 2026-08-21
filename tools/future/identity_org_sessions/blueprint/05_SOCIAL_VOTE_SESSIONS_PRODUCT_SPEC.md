# 05 — Social Vote Sessions Product Specification

## Goal

Create a product associations can pay for immediately because it solves a recurring operational
problem: asking structured questions during a meeting without forcing participants to register.

## Organizer flow

1. Open organization workspace.
2. Create Session.
3. Set title, date, expected participants and retention.
4. Add questions:
   - Yes/No
   - Single choice
   - Multiple choice
5. Select access/privacy mode.
6. Select result visibility.
7. Generate QR/join code.
8. Open question.
9. Participants vote.
10. Close question and move to next.
11. Close Session.
12. Export aggregate results / archive / delete / optionally publish aggregate outcome.

## Access modes

### A. Open anonymous
Use for low-stakes sentiment.

- join code/QR;
- no account;
- rate limit/device-local best-effort duplicate prevention;
- **must clearly say it is not guaranteed one-person-one-vote**.

### B. Controlled anonymous token pool — recommended
Use for association meetings and internal meetings.

Before the meeting:
- organizer generates N cryptographically random one-time credentials;
- Social Vote stores hashes only;
- credentials are shuffled/distributed without assigning names inside Social Vote.

During voting:
- participant presents token;
- server verifies token is valid for the Session;
- one token can cast at most one ballot per question;
- token-use ledger is separate from ballot-content ledger;
- ballot table has no participant/token foreign key;
- organizer never receives a token-to-ballot mapping.

Privacy claim:
- "anonymous to the organizer / no direct token-ballot link in the application data model"
- do **not** claim cryptographic/system anonymity yet.

For stronger future anonymity, use destructible per-session cryptographic linkage material or an
independent credential/ballot service.

### C. Roster confidential — later
Needed when the organizer must prove attendance/eligibility.

Keep:
- eligibility/attendance ledger;
- secret ballot ledger;
- no response history per member.

This mode has materially higher GDPR/legal risk and is not V1.

## Result visibility

Set before opening:
- live;
- after participant voted;
- after question closes;
- after entire Session closes;
- organizer only.

Changing to a less private mode after responses start should require explicit warning/audit or be
disallowed.

## Retention

Recommended presets:
- ephemeral: raw ballot data deleted 24h after Session close;
- short: 7 days;
- standard: 30 days;
- archive: aggregate report retained, raw ballot data deleted after defined period.

Default Free: 7 days.
Default paid: 30 days raw + aggregate archive unless organizer intentionally chooses shorter.

Do not expose:
- exact participant response timestamps to organizer;
- device/IP history;
- per-person response history;
- token IDs in exports.

## Aggregate privacy protections

For sensitive Sessions:
- no subgroup breakdown below minimum group size (initially 5);
- do not combine demographic filters that re-identify participants;
- exports aggregate-only by default;
- suppress exact timing;
- do not run advertising analytics on participant page.

## Question lifecycle

draft → open → closed

Voting only when:
- Session open;
- question open;
- credential valid;
- selection count valid;
- credential not already used for that question.

All checks server-side and atomic.

## Session lifecycle

draft → scheduled → open → closed → archived → deleting/deleted

Add:
- cancellation;
- automatic close;
- retention job;
- export snapshot hash;
- audit events for organizer actions.

## Public bridge

After Session close, organizer may create a **new public aggregate result object/Post** containing:
- question;
- aggregate totals/percentages;
- date;
- organization;
- methodology/access mode;
- participant count;
- optional notes.

Never publish credentials or secret ballot rows.

## Meeting UX

Presenter mode:
- large question;
- QR + short code;
- participant count (joined/eligible, not identities in anonymous mode);
- timer;
- open/close button;
- results;
- next question.

Participant:
- mobile browser;
- no install;
- no Social Vote account;
- minimal legal/privacy notice;
- code/token;
- question;
- submit once;
- receipt "vote received";
- result only if policy allows.

## What V1 deliberately does not do

- statutory quorum certification;
- member legal identity;
- proxies;
- weighted membership classes;
- secret-vote cryptography suitable for formal elections;
- signed meeting minutes;
- independent scrutineer certification;
- legally binding board elections;
- political/union election claims.

Those belong to Social Vote Governance.
