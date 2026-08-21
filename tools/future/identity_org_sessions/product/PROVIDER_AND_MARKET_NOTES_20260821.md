# Provider / market notes — 2026-08-21

This is a decision aid, not a vendor commitment.

## Phone verification
Supabase supports phone OTP / phone MFA through configured SMS providers. Social Vote should keep email/account authentication as its stable account identity and use verified phone possession as a verification factor rather than make the mobile number the sole account identity, because mobile numbers can be recycled.

Important implementation note: application-level uniqueness should remain server-authoritative. Social Vote's proposed HMAC claim table gives an explicit one-active-account-per-number rule independent of public profile data. If Supabase phone-change APIs are used, stale unconfirmed phone-change attempts must be handled because ambiguous phone-change state can exist.

## Identity document verification
Pilot recommendation: evaluate Stripe Identity first because its public Italian pricing is usage-based rather than a large monthly minimum. Current public pricing observed on 2026-08-21: EUR 1.25 per completed document + selfie verification, with the first 50 successful verifications advertised as free. Vendor/privacy/legal review is still required before activation.

## Live polling market benchmark
Current Poll Everywhere public business pricing observed on 2026-08-21 includes approximately USD 10/month annualized for Present, USD 49/month for Engage and USD 84/month for Teams, with paid reporting/participant controls and higher tiers for branding/support. This validates a paid organization polling category, but Social Vote should enter below mature-enterprise pricing during the Merano pilot.

## Commercial position
The Social Vote differentiation should not be "another presentation poll". The stronger bundle is:
- verified organization identity in the civic/social network;
- public Poll/Post communication when desired;
- private/ephemeral live Sessions when desired;
- accountless participant voting;
- controlled-anonymous one-time credentials;
- publishable aggregate outcome after a meeting, when the organizer chooses;
- one organization workspace that can later connect public consultation and internal meetings.
