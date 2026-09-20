# Authentication Specification

## Problem Statement

A reseller needs to sign in to see the catalog and, eventually, place orders. The app needs
email/password login, self-service sign-up, a password-recovery path, and a session that survives
app restarts without asking the reseller to log in every time.

## Goals

- [x] A reseller can create an account and sign in with email/password.
- [x] The session persists across launches (JWT in the Keychain) and routes automatically between
      the Auth flow and the Main flow.
- [ ] A reseller who forgets their password can actually recover the account (today's flow is a
      placeholder — see Edge Cases).

## Out of Scope

| Feature | Reason |
| --- | --- |
| Google Sign-In | Separate spec — `.specs/features/google-sign-in/spec.md`. Wiring exists but is unconfigured and crashes today. |
| Apple Sign-In | Separate spec — `.specs/features/apple-sign-in/spec.md`. Dead code today; no backend route. |
| Multi-tenant sign-up | `tenant_id` is a prepared column only (workspace `../STATE.md` §3 decision 3) — no tenant self-service sign-up. |
| Role/admin session data | Covered once Trello #188/#189 land (role in JWT + iOS session) — out of scope for this baseline spec. |

---

## Assumptions & Open Questions

| Assumption / decision | Chosen default | Rationale | Confirmed? |
| --- | --- | --- | --- |
| Forgot Password today silently calls `logout()` instead of resetting anything | Treated as a known defect, not a feature, and captured as an Edge Case below rather than a P1 requirement | The backend has no `/auth/reset` endpoint yet (Trello #96/#97); the current behavior is an unfinished placeholder (`ForgotPasswordViewModel.swift:34`) | y |
| Password strength rules (`PLPasswordStrengthBar`) | Documented as implemented behavior, not re-specified from scratch | This is a baseline spec for existing code, not a new design | y |

**Open questions:** none — all resolved or logged above.

---

## User Stories

### P1: Sign in with email and password ⭐ MVP

**User Story**: As a reseller, I want to log in with my email and password so that I can see the
catalog behind the login wall.

**Why P1**: without this, nothing else in the app is reachable.

**Acceptance Criteria**:

1. WHEN a reseller submits valid email/password credentials THEN the system SHALL exchange them for
   a JWT via `POST /login`, persist it in the Keychain, and route to the Main tab flow.
2. IF the credentials are rejected by the API THEN the system SHALL surface
   `error.localizedDescription` from `APIError` and SHALL NOT persist any token.
3. IF a required field (email or password) is empty THEN the system SHALL block submission with
   inline field validation before making a network call.
4. WHILE the login request is in flight the system SHALL disable the submit control and show a
   loading state.

**Independent Test**: fresh install, enter valid credentials, land on Home; enter wrong credentials,
see the API error toast, stay on Login.

---

### P1: Persist the session across launches ⭐ MVP

**User Story**: As a reseller, I want to stay logged in between app launches so that I don't have to
sign in every time I open the app.

**Why P1**: session-per-launch would make the app unusable day to day.

**Acceptance Criteria**:

1. The system SHALL check `KeychainService.isAuthenticated` at launch and route to the Main flow
   when true, or the Auth flow when false, via `AppCoordinator`.
2. WHEN a reseller logs out THEN the system SHALL clear the Keychain token and route back to the
   Auth flow.
3. WHEN `DELETE /users/{userId}` (account deletion) succeeds THEN the system SHALL clear the session
   the same way logout does.

**Independent Test**: log in, kill the app, relaunch — land on Home without re-authenticating. Log
out — land back on Login.

---

### P2: Self-service sign-up

**User Story**: As a new reseller, I want to create an account with my business details so that I
can start browsing and buying.

**Why P2**: required to grow the reseller base, but login already covers the demo-able core.

**Acceptance Criteria**:

1. WHEN a reseller submits name, email, password and password confirmation THEN the system SHALL
   call `POST /signup` and, on success, sign them in the same way login does.
2. IF the password and confirmation do not match THEN the system SHALL block submission with an
   inline error before calling the API.
3. WHERE phone or CPF/CNPJ are provided THEN the system SHALL include them in the sign-up payload;
   they are optional fields.
4. WHILE the reseller types a password the system SHALL render live strength feedback via
   `PLPasswordStrengthBar`.

**Independent Test**: sign up with a new email, land on Home already authenticated.

---

### P3: Password recovery (currently a placeholder)

**User Story**: As a reseller who forgot their password, I want to reset it so that I regain access
to my account.

**Why P3**: real recovery is blocked on backend endpoints that don't exist yet (Trello #95 AWS SES,
#96 `POST /auth/forgot-password`, #97 `POST /auth/reset-password`); today's screen only shows a
success state without doing anything real.

**Acceptance Criteria**:

1. WHEN the backend endpoints ship THEN the system SHALL call the real forgot/reset-password
   endpoints instead of the current placeholder.
2. The system SHALL NOT call `authService.logout()` from the Forgot Password screen — see Edge
   Cases; this is the immediate fix (Trello #86), independent of the endpoints shipping.

**Independent Test**: not demoable until #96/#97 ship; #86 alone is verifiable by confirming no
Keychain-clearing call happens when the screen is shown.

---

## Edge Cases

- IF `ForgotPasswordViewModel` is invoked today THEN it calls `authService.logout()` as a leftover
  placeholder (`Features/Auth/ForgotPassword/ForgotPasswordViewModel.swift:34`), which clears the
  Keychain even though the user is typically unauthenticated on that screen already. The screen then
  reports success unconditionally. This SHALL be replaced with a no-op (Trello #86) until the real
  endpoints exist — never leave a side-effecting placeholder that also lies about success.
- IF the API returns any non-2xx status THEN the system SHALL map it through `APIError` (401 →
  unauthorized, 409 → conflict, else → generic) and SHALL NOT show a raw status code to the user.

---

## Requirement Traceability

| Requirement ID | Story | Phase | Status |
| --- | --- | --- | --- |
| AUTH-01 | P1: Sign in | Specify | Shipped |
| AUTH-02 | P1: Sign in (error path) | Specify | Shipped |
| AUTH-03 | P1: Session persistence | Specify | Shipped |
| AUTH-04 | P2: Sign-up | Specify | Shipped |
| AUTH-05 | P3: Password recovery (real endpoints) | Specify | Pending — blocked on backend #95/#96/#97 |
| AUTH-06 | P3: Remove logout() placeholder | Specify | Pending — Trello #86 |

**ID format:** `AUTH-NN`.

**Coverage:** 6 total, 0 mapped to a formal `tasks.md` (Medium scope — tasks are implicit), 2
unmapped pending backend work (AUTH-05, AUTH-06) ⚠️.

---

## Success Criteria

- [x] A reseller can sign up, log in, and stay logged in across launches.
- [x] Login/sign-up failures surface a real, localized message — never a raw status code.
- [ ] Forgot Password stops silently wiping the Keychain (AUTH-06 — next, cheap fix).
- [ ] Forgot Password actually resets a password, end to end (AUTH-05 — blocked on backend).
