# Future Edge Function contracts — Social Vote Sessions

## Organizer endpoints
Require authenticated membership in a verified-organization workspace.
- create/update/open/close/archive/delete session
- create/update/reorder/open/close question
- generate controlled-anonymous token batch
- read results/export

## Participant endpoints
No Social Vote account required.

### join
Input: session join code + optional one-time access token.
Returns a short-lived participant credential.

For controlled anonymous mode the server stores only a cryptographic hash of the distributed access token.

### vote
Input: participant credential + question id + selected option ids.
Server validates:
- session/question open;
- credential belongs to session;
- selection limits;
- no prior vote for that question;
- atomic insertion.

### results
Server enforces `results_visibility` and never leaks participant-token identifiers.

## Deletion
Session deletion cascades questions, access tokens and raw votes. Retention jobs must enforce 24h/7d/30d policies.
