# Profile Specification

## Problem Statement

A reseller needs to see and manage their own account. Today the Profile screen shows a settings
menu and log-out/delete-account actions that work for real, but the identity it displays —
name, email, avatar — is hardcoded, not fetched. Trello #88/#89 are next in the board's Phase 1 to
fix exactly that.

## Goals

- [x] A reseller can log out or delete their account for real.
- [ ] A reseller sees their actual name, email and avatar, not placeholder text (next — #88/#89).
- [ ] A reseller can edit their profile (blocked on a backend endpoint that doesn't exist — #90).

## Out of Scope

| Feature | Reason |
| --- | --- |
| Role / admin surface in Profile | Blocked on backend #186–#188 (role model, role in JWT/`GET /profile`) — tracked separately once that lands. |
| Notifications / Security / Help & Support sub-screens | Each row is a `Button` with a `// TODO: navigate to sub-screen` today (`ProfileView.swift:109`) — real screens are Trello #100/#101, not yet designed in enough detail for a spec here. |

---

## Assumptions & Open Questions

| Assumption / decision | Chosen default | Rationale | Confirmed? |
| --- | --- | --- | --- |
| Where profile data comes from once #88/#89 ship | `GET /profile`, which the backend already implements and documents, via a new `ProfileService` + `UserProfile` model — no route exists in `APIEndpoint` yet | `HANDOFF.md` §5.4: the endpoint exists server-side but was never wired into `APIEndpoint` | y |
| Avatar rendering | `PLRemoteImage` (Kingfisher wrapper), same as every other remote image in the app | Never a bespoke image-loading path per `.claude/CLAUDE.md` Design System rules | y |
| Whether `PUT /profile` (edit) is in scope now | No — tracked as a separate P3 story, blocked on backend #90 which doesn't exist yet | Workspace `../STATE.md` §3 decision 8: the original card stayed in "ENTREGUES EM 2026.1" for historical reasons, but the real work is new card #90 | y |

**Open questions:** none — all resolved or logged above.

---

## User Stories

### P1: Real profile data ⭐ MVP (next)

**User Story**: As a reseller, I want the Profile screen to show my actual name, email and avatar,
so I know I'm looking at my own account.

**Why P1**: cheapest visible win left in the app per `HANDOFF.md` §6 step 6 — the backend endpoint
already exists, only the iOS side is missing.

**Acceptance Criteria**:

1. WHEN the Profile screen appears THEN the system SHALL fetch `GET /profile` through a new
   `ProfileService` and render the real name and email, replacing the `"Your Name"` /
   `"your@email.com"` literals at `ProfileView.swift:48,51`.
2. WHERE the profile has an image URL THEN the system SHALL render it via `PLRemoteImage`, replacing
   the current static SF Symbol avatar.
3. IF `GET /profile` fails THEN the system SHALL surface the mapped `APIError` and SHALL NOT show
   stale or placeholder identity data as if it were real.
4. The system SHALL add `.getProfile` to `APIEndpoint` rather than constructing the request ad hoc
   at the call site — per the "adding a route means adding a case" rule.

**Independent Test**: log in as a known account, open Profile, see that account's real name/email/
avatar instead of the placeholder literals.

---

### P1: Log out and delete account ⭐ MVP (already shipped)

**User Story**: As a reseller, I want to log out or delete my account so I control my own session
and data.

**Why P1**: already real and working — documented here as the shipped baseline this spec builds on.

**Acceptance Criteria**:

1. WHEN a reseller taps Log Out THEN the system SHALL clear the Keychain session and route to the
   Auth flow.
2. WHEN a reseller taps Delete Account and confirms THEN the system SHALL call
   `DELETE /users/{userId}` and, on success, clear the session the same way logout does.

**Independent Test**: log out — land on Login; create a throwaway account, delete it, confirm the
session clears.

---

### P3: Edit profile (blocked on backend)

**User Story**: As a reseller, I want to edit my name/email/phone so I can keep my account current.

**Why P3**: the settings row already exists as a `TODO`, but there's no backend endpoint to call yet.

**Acceptance Criteria**:

1. WHEN `PUT /profile` (Trello #90) ships THEN the system SHALL build an Edit Profile screen
   (Trello #91) that calls it and reflects the update on return to Profile.
2. Until #90 ships, the Edit Profile row SHALL either stay a `showComingSoon()` action or be
   removed — it SHALL NOT navigate to a broken/empty screen.

**Independent Test**: not demoable until #90 ships.

---

## Edge Cases

- IF `GET /profile` has not yet returned when Profile first renders THEN the system SHALL show a
  loading state, not the old hardcoded literals — no intermediate frame should look like real data
  when it isn't.
- IF the account has no profile image THEN `PLRemoteImage` SHALL fall back to a placeholder
  consistent with the rest of the app, not a broken image state.

---

## Requirement Traceability

| Requirement ID | Story | Phase | Status |
| --- | --- | --- | --- |
| PROF-01 | P1: real name/email fetch | Specify | Pending — next up, Trello #88/#89 |
| PROF-02 | P1: real avatar | Specify | Pending — same cards |
| PROF-03 | P1: fetch error handling | Specify | Pending |
| PROF-04 | P1: `.getProfile` endpoint case | Specify | Pending |
| PROF-05 | P1: log out | Specify | Shipped |
| PROF-06 | P1: delete account | Specify | Shipped |
| PROF-07 | P3: edit profile | Specify | Pending — blocked on backend #90 |

**ID format:** `PROF-NN`.

**Coverage:** 7 total, 2 shipped, 4 next (PROF-01–04), 1 blocked on backend (PROF-07) ⚠️.

---

## Success Criteria

- [x] Log out and delete account work end to end today.
- [ ] Profile shows the logged-in reseller's real identity, not placeholder text (PROF-01–04).
- [ ] Edit Profile exists once the backend supports it (PROF-07).
