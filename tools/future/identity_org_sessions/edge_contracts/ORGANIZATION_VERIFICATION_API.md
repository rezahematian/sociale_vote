# Organization Verification API — Future Contract

## POST /organizations

Auth: authenticated L1 user.

Creates unverified organization entity.
Input:
- legal_name
- public_name
- entity_type
- country
- fiscal_code / VAT as applicable
- registry_type/reference
- website

## POST /organizations/{id}/verification/submit

Checks requester membership/ownership.

Server:
- registry adapter query where possible;
- generate evidence snapshot;
- request representative-authority challenge/evidence;
- create verification case.

## POST /organizations/{id}/authority/challenge

Modes:
- official-domain email;
- PEC/manual;
- registry representative;
- signed delegation.

Never auto-verify from display name/domain alone.

## POST /admin/organizations/{id}/verification/decide

Admin capability only.
Input:
- decision
- reason code
- note
- evidence references
- reverify_after

Billing status is not an input.

## POST /organizations/{id}/members/invite

Owner/manager.
Invited user becomes operator only after account/auth acceptance.

## POST /organizations/{id}/ownership-transfer

Strong verification.
May require Admin when disputed/unavailable owner.

Every verification and ownership mutation is audited.
