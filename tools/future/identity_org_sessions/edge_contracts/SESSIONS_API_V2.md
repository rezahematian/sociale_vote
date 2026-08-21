# Social Vote Sessions API V2 — Privacy-Safe Future Contract

## Organizer authorization

Authenticated organization member + entitlement + workspace role.

## POST /sessions
Create draft Session.

## PATCH /sessions/{id}
Allowed only while settings are mutable.
Privacy/result settings become locked or restricted after first ballot.

## POST /sessions/{id}/tokens/generate

Controlled anonymous only.

Input:
```json
{"count":80}
```

Server:
- generate CSPRNG tokens;
- store only hashes;
- return plaintext token batch once;
- no participant names;
- no later API to recover plaintext.

Organizer should shuffle/distribute credentials without recording assignments inside Social Vote.

## POST /participant/join

Input:
- join code;
- token if controlled mode.

Return short-lived Session participant credential.
Do not create Social Vote auth user.

## POST /participant/questions/{id}/vote

Atomic server function:
1. validate Session/question open;
2. validate selections;
3. resolve token hash;
4. insert unique token-question-use row;
5. insert ballot row with selected options **without token/user FK**;
6. return opaque receipt.

If step 4 conflicts, transaction fails and no ballot is inserted.

Open anonymous mode uses a separate best-effort anti-abuse credential and must not claim guaranteed
one-person-one-vote.

## GET /sessions/{id}/results

Server enforces visibility policy.
Organizer result payload:
- aggregates;
- eligible/generated-token count where appropriate;
- number of responses;
- no token IDs;
- no participant-level history;
- no IP/device identifiers.

## POST /sessions/{id}/close

Locks voting and starts retention schedule.

## POST /sessions/{id}/exports

Entitlement required.
Export aggregate by default.
No token mapping.

## DELETE /sessions/{id}

Soft-delete control record as needed for audit, but delete ballots/token material according to
retention/legal policy.

## POST /sessions/{id}/publish-aggregate

Creates a new public aggregate artifact/Post only after explicit organization action.
No raw ballot/credential data leaves private Session storage.
