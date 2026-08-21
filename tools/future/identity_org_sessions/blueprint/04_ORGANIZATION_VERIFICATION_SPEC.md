# 04 — Verified Organization Specification

## Core rule

**The organization is an entity. The human account is an operator/representative.**

The old V1 foundation tied an organization profile directly to one `user_id`. V2 corrects that future
model: one organization can have multiple authorized human operators and can survive operator changes.

This does not require changing CURRENT release code now. It is a post-release extension.

## Supported organization classes

1. ETS / APS / ODV / other RUNTS entity.
2. ASD / SSD in the national sports register.
3. Company / cooperative / registered enterprise.
4. Public institution / municipality / public body.
5. Other nonprofit/association not in a public register.
6. International organization — later registry adapters.

## Data requested from organization

Minimum common fields:
- legal name;
- public/display name;
- country;
- legal/entity type;
- tax/fiscal code where applicable;
- VAT number where applicable;
- registered/legal address if needed for billing/registry match;
- official website/public page where available;
- registry type;
- registry reference;
- official-domain/PEC contact where applicable;
- requester account;
- requester role/title.

Do not ask for all documents by default.

## Registry-first verification

### ETS
Use RUNTS when applicable:
- search by denomination;
- municipality;
- section/type;
- tax code;
- repertory number;
- inspect public entity information/documents as needed.

The RUNTS exists specifically to provide public transparency on registered ETS.

### Company/cooperative
Use the official Registro Imprese/Camera di Commercio:
- legal name;
- CF/P.IVA/REA;
- registered office;
- current status;
- administrators;
- powers/delegations/signature authority as needed.

### ASD/SSD
Use the Registro Nazionale delle Attività Sportive Dilettantistiche when applicable. Registration
certifies the sporting amateur nature of the entity.

### Public institution
Verify through official government/municipal registry/domain and institutional contact. Do not
classify an entity as a public institution solely because its display name looks official.

## Representative authority

Entity existence and requester authority are separate checks.

Accept one or more:
1. requester appears as legal representative/officer in official registry;
2. official PEC challenge;
3. official-domain email challenge plus registry match;
4. signed delegation/appointment act from an authorized representative;
5. recent official minutes/resolution appointing the requester;
6. manual verification escalation.

For high-risk organization ownership:
- requester should have at least Persona L1;
- Persona L2 can be required when registry/authority evidence is weak or when the organization is
  requesting governance-grade features later.

## No public registry case

Request only what is necessary:
- constitution/statute;
- tax-code or registration allocation;
- current representation/appointment evidence;
- official contact;
- optional recent meeting minutes only if needed to establish authority.

Raw evidence:
- private;
- staff access audited;
- no normal moderator access unless required;
- delete after review when possible;
- keep hashes/reference/decision rather than unnecessary full files.

## Organization verification state

- draft
- submitted
- needs_information
- verified
- rejected
- suspended
- expired

Keep reason codes and human review notes separate from public data.

## Reverification

Recommended:
- 24 months for low-risk registry-backed entities;
- 12 months for high-risk/manual-evidence entities;
- immediate review on representative/owner change;
- immediate review on registry cancellation/suspension;
- event-driven recheck when credible impersonation report arrives.

Verification decision remains independent from commercial plan.

## Public fields

Public:
- verified public name;
- organization type;
- country/city;
- registry category/reference when appropriate;
- verification date/state;
- official website.

Private:
- representative phone;
- delegation evidence;
- raw documents;
- billing contacts;
- internal review notes;
- risk/fraud signals.

## Owner transfer

An organization must not disappear or lose access because one operator leaves.

Transfer flow:
1. new representative submits authority evidence;
2. existing owner approves when available;
3. Admin verifies if owner unavailable/disputed;
4. audit old/new ownership;
5. revoke former operator;
6. keep organization/public history stable.
