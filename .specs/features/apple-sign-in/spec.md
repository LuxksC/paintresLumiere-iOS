# Apple Sign-In Specification

## Problem Statement

`APIEndpoint.authApple` (`Networking/APIEndpoint.swift:9,21,78`) and
`AuthService.authenticateWithApple` (`Services/Auth/AuthService.swift:38`) already point at
`POST /auth/apple` — a route that does not exist anywhere in `paintresLumiere-api` (not in
`serverless.yml`, `docs/openapi.yaml`, or `src/controllers/`). Nothing calls this code today, so
it's dead code, not a live bug — but it will 404 the moment a button gets wired to it. Separately,
App Store review requires Sign in with Apple whenever a third-party social login (Google) is
offered, so this becomes mandatory the moment `.specs/features/google-sign-in/spec.md` ships.

## Goals

- [ ] A reseller can sign in with Apple ID, on both Welcome and Login, once the backend route is real.
- [ ] Until then, the dead client code does not mislead anyone into thinking this is implemented.

## Out of Scope

| Feature | Reason |
| --- | --- |
| Google Sign-In | Separate spec — this one only references it as the reason Apple Sign-In became mandatory. |
| Account linking (Apple ↔ existing account, email relay handling) | Not raised in any source doc yet; revisit when the backend route is actually designed (Trello #92). |

---

## Assumptions & Open Questions

| Assumption / decision | Chosen default | Rationale | Confirmed? |
| --- | --- | --- | --- |
| What to do with the current dead `authApple` client code while the backend route doesn't exist | Leave it in place but treat it as not-yet-implemented (this spec), rather than deleting it | Workspace `../STATE.md` §3 decision 5 already commits to implementing Sign in with Apple for real (cards #92 backend, #93 design, #94 iOS) — deleting now would just be re-added work | y |
| Backend contract shape for `POST /auth/apple` | Not assumed — must be agreed with the API side before iOS implementation starts | `.claude/CLAUDE.md`'s "Backend contract" section requires agreeing cross-repo payload shapes before implementing anything that crosses the boundary | y |

**Open questions:** none — all resolved or logged above.

---

## User Stories

### P1: Sign in with Apple ⭐ MVP (once the backend route exists)

**User Story**: As a reseller, I want to sign in with my Apple ID so that I have a privacy-focused
alternative to Google.

**Why P1**: mandatory the moment Google Sign-In ships, per App Review guidelines — not optional
once that condition is true.

**Acceptance Criteria**:

1. WHEN a reseller taps "Sign in with Apple" on Welcome or Login and completes the system Apple ID
   flow THEN the system SHALL send the resulting identity token, email and full name to
   `POST /auth/apple` via `AuthService.authenticateWithApple`.
2. WHEN `POST /auth/apple` succeeds THEN the system SHALL persist the returned JWT and route to Main,
   identically to email/password and Google sign-in.
3. IF the reseller cancels the system Apple ID sheet THEN the system SHALL return to the previous
   screen without an error toast.
4. IF `POST /auth/apple` rejects the exchange THEN the system SHALL surface the mapped `APIError`
   message.
5. The system SHALL request only the minimum Apple ID scopes needed (name, email) — no scope creep.

**Independent Test**: not demoable until Trello #92 (backend route) ships; once it does, tap the
button, complete the system Apple ID sheet, land on Home authenticated.

---

### P2: Button placement per design

**User Story**: As a reseller, I want Sign in with Apple to appear wherever Google Sign-In appears,
so the choice feels equivalent.

**Why P2**: cosmetic/placement detail, secondary to the auth exchange itself.

**Acceptance Criteria**:

1. WHERE the Google Sign-In button is present on Welcome or Login THEN the Apple Sign-In button
   SHALL be present alongside it, per the design spec tracked in Trello #93.

**Independent Test**: visually confirm both buttons appear together on both screens.

---

## Edge Cases

- IF the backend route does not exist yet (today's actual state) THEN the client code SHALL remain
  unreachable from the UI — no button currently calls `authenticateWithApple`, and that must stay
  true until #92 ships, or every tap 404s.
- IF the cross-repo payload contract changes shape during backend design (#92) THEN this spec's
  ACs 1–2 SHALL be updated before iOS implementation starts, per the "agree the payload shape first"
  rule in `.claude/CLAUDE.md`.

---

## Requirement Traceability

| Requirement ID | Story | Phase | Status |
| --- | --- | --- | --- |
| ASI-01 | P1: sign-in exchange | Specify | Pending — blocked on backend #92 |
| ASI-02 | P1: session persistence | Specify | Pending — blocked on ASI-01 |
| ASI-03 | P1: cancellation | Specify | Pending |
| ASI-04 | P1: error path | Specify | Pending |
| ASI-05 | P1: minimal scopes | Specify | Pending |
| ASI-06 | P2: button placement | Specify | Pending — blocked on design #93 |

**ID format:** `ASI-NN`.

**Coverage:** 6 total, 0 mapped to tasks, 6 unmapped — entirely blocked on backend + design ⚠️.

---

## Success Criteria

- [ ] `POST /auth/apple` exists on the backend and this client code is exercised for real.
- [ ] No build ships with a button pointing at a 404.
