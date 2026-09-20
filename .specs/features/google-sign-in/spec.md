# Google Sign-In Specification

## Problem Statement

The app ships a Google Sign-In button, a `GoogleSignInHelper`, a `LoginViewModel` method and a
backend `POST /auth/google` route — but the iOS app is not configured for it. Tapping the button
today raises a fatal error (`GIDSignIn` requires a `clientID`), which is a crash, not a graceful
failure. This spec captures what "done" means so the button either works end to end or is not on
screen.

## Goals

- [ ] A reseller can sign in with their Google account and land authenticated on Home, exactly like
      email/password login.
- [ ] Until that's configured, the button never crashes the app.

## Out of Scope

| Feature | Reason |
| --- | --- |
| Apple Sign-In | Separate spec — `.specs/features/apple-sign-in/spec.md`. Only relevant here because shipping Google Sign-In makes Apple Sign-In mandatory per App Review guidelines. |
| Account linking (Google ↔ existing email/password account) | Not raised in `HANDOFF.md` or Trello; treated as future scope if it comes up. |

---

## Assumptions & Open Questions

| Assumption / decision | Chosen default | Rationale | Confirmed? |
| --- | --- | --- | --- |
| Whether to hide the button or configure Google Sign-In first | Hide the button behind a flag/condition until configuration lands, rather than shipping a crash | `HANDOFF.md` §5.1 explicitly recommends this; a crashing login button is worse than a missing feature | y |
| Who provisions the OAuth client ID | Product owner (Lucas) — Trello #77 "Criar projeto e OAuth client ID no Google Cloud" is a `[Gestão]` card, not an iOS engineering task | Only the account owner can create the Google Cloud project | y |

**Open questions:** none — all resolved or logged above.

---

## User Stories

### P1: Configure Google Sign-In end to end ⭐ MVP

**User Story**: As a reseller, I want to sign in with my Google account so that I don't need a
separate password for this app.

**Why P1**: it's already half-built; finishing it is cheaper than leaving it broken.

**Acceptance Criteria**:

1. The system SHALL declare `GIDClientID` in `Info.plist`, sourced from the OAuth client ID Trello
   #77 provisions — never hardcoded inline in Swift.
2. The system SHALL declare a `CFBundleURLTypes` entry for the reversed client ID so Google's OAuth
   redirect completes.
3. WHEN a reseller taps "Sign in with Google" and completes the Google consent flow THEN the system
   SHALL call `LoginViewModel.requestGoogleSignIn()`, exchange the Google token with
   `POST /auth/google`, persist the returned JWT the same way email/password login does, and route
   to Main.
4. IF the reseller cancels the Google consent flow THEN the system SHALL return to the Login screen
   without any error toast (cancellation is not a failure).
5. IF `POST /auth/google` rejects the exchange THEN the system SHALL surface the mapped `APIError`
   message, same as email/password login's error path.

**Independent Test**: with a real `GIDClientID` configured, tap the button, complete Google consent
in the simulator/device, land on Home authenticated.

---

### P2: Never crash when unconfigured

**User Story**: As a reseller using a build where Google Sign-In isn't configured yet, I want the
login screen to just not offer that option, instead of the app crashing.

**Why P2**: this is the safety net while P1 is still in flight — it's what makes the button safe to
ship incrementally.

**Acceptance Criteria**:

1. IF `GIDClientID` is not present in the running configuration THEN the system SHALL NOT render the
   Google Sign-In button at all, rather than rendering a button that crashes on tap.
2. The system SHALL NOT call `GIDSignIn.sharedInstance.signIn(...)` from any code path when the
   client ID is absent.

**Independent Test**: run a build with no `GIDClientID` in `Info.plist` — confirm the button is
absent from Login/Welcome and the app never calls `GIDSignIn`.

---

## Edge Cases

- IF the OAuth client ID (#77) is not yet provisioned THEN P1 cannot start — this is the actual
  current state, and P2 is the interim requirement that applies today.
- IF Google's SDK returns a token but the backend has never seen this Google account before THEN
  `POST /auth/google` is expected to create the account server-side (confirm the exact contract
  against `paintresLumiere-api`'s `docs/openapi.yaml` before wiring P1 — do not assume).

---

## Requirement Traceability

| Requirement ID | Story | Phase | Status |
| --- | --- | --- | --- |
| GSI-01 | P1: Info.plist config | Specify | Pending — blocked on Trello #77 (owner action) |
| GSI-02 | P1: URL scheme | Specify | Pending — blocked on Trello #77 |
| GSI-03 | P1: sign-in exchange | Specify | Pending — blocked on GSI-01/02 |
| GSI-04 | P1: cancellation | Specify | Pending |
| GSI-05 | P1: error path | Specify | Pending |
| GSI-06 | P2: hide when unconfigured | Specify | Pending — do this regardless of #77's timeline |
| GSI-07 | P2: never call SDK unconfigured | Specify | Pending |

**ID format:** `GSI-NN`.

**Coverage:** 7 total, 0 mapped to tasks yet, 7 unmapped — this feature has not started ⚠️.

---

## Success Criteria

- [ ] The button either fully works or is not shown — no build ships a crashing tap target.
- [ ] Google Sign-In produces the same authenticated session shape as email/password login.
