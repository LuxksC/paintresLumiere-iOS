# Handoff — Paintres Lumiere iOS

Status snapshot taken on **2026-08-30**. Written for whoever (human or agent) picks the project back up after the 2026.1 cycle.

Companion document: `HANDOFF.md` in `paintresLumiere-api`.

---

## 1. What this project is

Paintres Lumiere is a **B2B sales app** for a workshop that manufactures laser-cut pieces and sells them to resellers. The reseller should be able to browse a catalog, build a cart, pay (boleto instalments / card / pix) and track the order through production and delivery.

**This repo is the iOS client.** It currently covers authentication, a product catalog and product details. Cart, checkout and order tracking do not exist yet — the buttons are wired to "Coming soon" toasts.

Sources of truth:
- Proposal PDF — Trello card #9 "Elaborar proposta do projeto"
- 2026.1 report PDF — Trello card #70 "Relatório do projeto" (16 pages; §Frontend describes this app in detail)
- Trello board: https://trello.com/b/L9Bg9uhU
- Figma: https://www.figma.com/design/PEEatw9wg2MZJXRnaKsKnU/Paintres-Lumiere
- Backend contract: `README.md` and `docs/openapi.yaml` in `paintresLumiere-api`

~50h of the project's ~153h went into this app.

---

## 2. Current state

| | |
|---|---|
| Default branch | `main` @ `363913b` (merge of PR #2) |
| Open PRs / issues | None |
| Local `main` | **Stale** — run `git checkout main && git pull` before starting |
| Local checkout | Sitting on `PL-54/refactor/ls/update_project_architecture` (already merged, safe to delete) |
| `develop` branch | Behind `main` by one PR — either fast-forward it or delete it, currently it is just confusing |
| Build | ✅ Clean (verified via Xcode, 0 errors, 0 navigator issues) |
| Tests | **None** — `PaintresLumiereTests.swift` is the Xcode stub with an empty `@Test func example()` |
| CI | **None** (no `.github/`) |

### Build settings worth knowing

| Setting | Value | Note |
|---|---|---|
| `IPHONEOS_DEPLOYMENT_TARGET` | `26.1` | Very aggressive. Anything below iOS 26.1 cannot install the app. |
| `SWIFT_VERSION` | `5.0` | Language mode 5, **not** Swift 6 — despite `.claude/CLAUDE.md` claiming Swift 6.2. |
| `SWIFT_APPROACHABLE_CONCURRENCY` | `YES` | |
| `PRODUCT_BUNDLE_IDENTIFIER` | `com.luxkasTech.PaintresLumiere` | |
| `DEVELOPMENT_TEAM` | `966B95DH9Z` and `VMS7N3ZWG9` | **Two different teams across configurations** — will bite on device builds. |
| Orientation | Portrait only (iPhone) | |

### Dependencies (SPM)

`Swinject` 2.10 (DI) · `GoogleSignIn-iOS` 9.1 (+ its transitive AppAuth / GTM / GoogleUtilities / promises / app-check) · `Kingfisher` 8.9 (remote images).

---

## 3. Architecture

**MVVM-C** on a **UIKit app lifecycle** with SwiftUI views hosted inside `UIHostingController`s. This was a deliberate choice (Trello #54 "Estudar arquiteturas", #55 "Refatorar arquitetura") so that navigation stays out of the views and both UIKit and SwiftUI remain available.

```
PaintresLumiere/PaintresLumiere/
├── Application/        AppDelegate, SceneDelegate, AppCoordinator, LaunchScreen
├── Commons/            shared extensions + the Coordinator protocol
├── DesignSystem/       PLColors, PLTypography, PLSpacing, Inter fonts, PL* components
├── DI/                 DependencyContainer + Assemblies (Network, Services, Auth, Main)
├── Features/
│   ├── Auth/           Login, SignUp, ForgotPassword (+ AuthCoordinator)
│   ├── Main/           MainTabCoordinator, Home, Library, Profile
│   └── Products/       ProductDetails + the Product model family
├── Networking/         APIClient, APIEndpoint, APIError, JsonHelper, Mocks/
└── Services/           Auth, Products, Keychain, GoogleSignInHelper, Messages (toasts)
```

**Navigation.** `AppCoordinator` owns the `UIWindow` and switches between the Auth flow and the Main tab flow based on `KeychainService.isAuthenticated`. Each feature has its own coordinator. ViewModels never see a concrete coordinator — only a protocol (`AuthCoordinatorProtocol`, `HomeCoordinatorProtocol`, `ProfileCoordinatorProtocol`, `ProductDetailsCoordinatorProtocol`) held `weak`.

**DI.** Swinject. `DependencyContainer` composes `NetworkAssembly` + `ServicesAssembly` + `AuthAssembly` + `MainAssembly`; `AppDelegate` owns it and exposes a `Resolver` that flows down through the coordinators.

**Networking.** `APIClient` wraps `URLSession` with `async/await`. `APIEndpoint` is a single enum holding every route (path, method, query, body) and attaches `Authorization: Bearer` from the Keychain automatically. `APIError` maps status codes to user-facing messages. Base URL lives in `NetworkConfig.baseURL` — currently the hardcoded production API Gateway host.

**Feedback.** `MessagesService` renders global toasts through `ToastHostView` attached to the window scene — used for network errors, confirmations and "Coming soon".

**Design System.** Tokens in `PLColors` / `PLTypography` / `PLSpacing`, Inter font family with Dynamic Type support. Components: `PLButton` (5 variants), `PLInputField`, `PLPasswordStrengthBar`, `PLProductCard`, `PLColorSelector`, `PLSizeSelector`, `PLQuantityStepper`, `PLRemoteImage` (Kingfisher wrapper), `PLBadge`, `PLDivider`, `PLPageIndicator`.

---

## 4. What is implemented

Everything below was signed off in the Trello list "ENTREGUES EM 2026.1".

**Auth flow** (#43, #44, #72) — Login with email/password (field validation, API error surfacing), Sign Up (name/email/password required; phone/CPF/CNPJ optional; password confirmation + strength bar), Forgot Password screen with a success state, JWT persisted in the Keychain, automatic routing between the auth and main flows based on token presence.

**Home** (#61) — Catalog from `GET /products` and `GET /products/popular?limit=5`, laid out as a horizontal "Most popular" carousel plus a 2-column "Our collection" grid. Loading / error (with retry) / empty states. Pull-to-refresh. Bell and cart icons fire "Coming soon" toasts.

**Library** (#35) — Empty state only. Intended to hold user-uploaded SVG files for the (now questioned) laser-cut-file feature. Upload is not implemented.

**Profile** (#58) — Settings menu (Edit Profile, Notifications, Security, Help & Support) plus Log Out and Delete Account, both wired to their real endpoints.

**Product details** — The most complex screen. Image carousel with page indicator, name/price with promo price and discount badge, description, **variant-aware** color and size selectors (an option is disabled when no variant exists for the current pairing), spec section (category, dimensions, barcode, SKU), stock indicator, quantity stepper capped at the selected variant's stock. Buy / Add-to-cart show "Coming soon".

**Design System in code** (#53) and **LaunchScreen** (#32).

---

## 5. Gaps and known issues

Ordered roughly by how much they will bite.

### 5.1 Google Sign-In will fail at runtime

The plumbing exists — `GoogleSignInHelper`, the button, `LoginViewModel.requestGoogleSignIn()`, `SceneDelegate.scene(_:openURLContexts:)`, the backend's `POST /auth/google` — but **the app is not configured for it**:

- `Info.plist` has no `GIDClientID`
- `Info.plist` has no `CFBundleURLTypes` entry for the reversed client ID
- there is no `GoogleService-Info.plist` anywhere in the repo

`GIDSignIn.sharedInstance.signIn(...)` raises a fatal "You must specify |clientID|" without a configuration, so tapping the Google button is a **crash**, not a graceful failure. The 2026.1 report acknowledges this was left unfinished. Either configure it or hide the button.

### 5.2 Forgot Password silently calls `logout()`

`Features/Auth/ForgotPassword/ForgotPasswordViewModel.swift:34`:

```swift
_ = try? await authService.logout() // placeholder until /auth/reset is added
```

`AuthService.logout()` calls `keychain.clearAll()`. Today the user is unauthenticated on that screen so nothing visible breaks, but it is a side-effecting placeholder that wipes the Keychain, and the screen then reports success regardless. The backend has no reset endpoint at all (see the API handoff, §4.3). **Fix by making this a no-op with an explicit `// TODO` until the endpoint exists**, then wire it for real.

### 5.3 Apple Sign-In points at an endpoint that does not exist

`APIEndpoint.authApple` (`Networking/APIEndpoint.swift:9,21,78`) and `AuthService.authenticateWithApple` (`Services/Auth/AuthService.swift:38`) target `POST /auth/apple`. **The backend has no such route** — it is not in `serverless.yml`, `docs/openapi.yaml` or `src/controllers/`. Nothing in the UI calls this path today, so it is dead code, but it will 404 the moment someone wires a button to it.

Note that App Store review requires Sign in with Apple whenever a third-party social login is offered — so if Google Sign-In (§5.1) ships, this needs to become real on both sides.

### 5.4 Profile shows hardcoded data

`Features/Main/Profile/ProfileView.swift:48,51` render the literals `"Your Name"` and `"your@email.com"`. There is no `ProfileService`, and `GET /profile` — which the backend has implemented and documented — is not in `APIEndpoint` at all. So the Profile screen never shows who is logged in. The avatar is a static SF Symbol; `users.image` is never fetched or displayed.

The four settings rows (`ProfileView.swift:109`) are `Button`s with a `// TODO: navigate to sub-screen` body. "Edit Profile" additionally needs a backend endpoint that does not exist yet.

### 5.5 The whole purchase flow is missing

No cart, no checkout, no payment, no order history, no order tracking. Every entry point is a `showComingSoon()` toast (`HomeCoordinator.homeDidTapCart()`, the Buy / Add-to-cart buttons). This is the core of what the app is supposed to do, and it is blocked on the backend building it first.

### 5.6 No tests

`PaintresLumiereTests.swift` is the untouched Xcode template. The architecture was specifically chosen so ViewModels are testable — `ProductDetailsViewModel`'s variant-constraint logic (`enabledColors`, `enabledSizes`, `selectedVariant`, `maxQuantity`) is dense, pure and the single most valuable thing to cover. `PreviewAuthService` and `PreviewProductService` already exist and can serve as test doubles.

### 5.7 The repo's `CLAUDE.md` contradicts the project

`.claude/CLAUDE.md` is a generic modern-SwiftUI guide. Several of its rules are the opposite of what this codebase does:

| `CLAUDE.md` says | Reality |
|---|---|
| "Avoid UIKit unless requested" | UIKit app lifecycle, `UIHostingController`s, `UINavigationController`-driven coordinators |
| "Swift 6.2 or later" | `SWIFT_VERSION = 5.0` |
| "Do not introduce third-party frameworks without asking" | Swinject, GoogleSignIn, Kingfisher are all in |
| Views navigate via `navigationDestination(for:)` / `NavigationStack` | Navigation is entirely coordinator-driven |
| Prefer `Localizable.xcstrings` symbol keys | All strings are hardcoded English literals |

An agent following it literally will fight the architecture. It should be rewritten to describe MVVM-C + Swinject + the Design System + the coordinator protocol convention, keeping the genuinely useful modern-Swift rules (`@Observable`, `foregroundStyle`, `clipShape(.rect(...))`, no `DispatchQueue`, no `DateFormatter`, etc.). Note it is currently the **only** tracked file under `.claude/`.

### 5.8 Smaller items

- **DI fallbacks hide misconfiguration.** `MainAssembly` and `HomeCoordinator` both do `resolver.resolve(X.self) ?? X(apiClient: APIClient())`. If a registration is ever dropped, the app silently builds a second, unconfigured object graph instead of failing loudly.
- **Two `DEVELOPMENT_TEAM` values** across build configurations — will cause signing failures on device.
- **`NetworkConfig.baseURL` is a hardcoded production URL.** No dev/staging switch, no `.xcconfig`.
- **Deployment target 26.1** rules out essentially the whole installed base. Fine for a course project; not fine for real resellers.
- **No localization.** All copy is English string literals, but the users (Brazilian resellers) are PT-BR speakers.
- **`.DS_Store` files are tracked** (`PaintresLumiere/.DS_Store`, `.claude/.DS_Store`) and show as modified. Add to `.gitignore` and `git rm --cached`.
- **Figma has drifted from the code** — tracked as Trello #64. Trello #67 ("Updates HomeView") also asks for the Home layout to be reworked into a 2×n grid of *product categories*, because the design drifted toward the laser-cut-file tool instead of selling.

---

## 6. Proposed next steps

Phased so each phase leaves the app shippable.

### Phase 0 — Housekeeping (half a day)

1. `git checkout main && git pull`; delete the merged local branch; fast-forward or delete `develop`.
2. Gitignore and untrack `.DS_Store`.
3. Unify `DEVELOPMENT_TEAM` across configurations.
4. Rewrite `.claude/CLAUDE.md` to match the real architecture (§5.7).
5. Decide the deployment target. iOS 17 or 18 would be a more defensible floor than 26.1.

### Phase 1 — Finish what is already half-built (3–5 days)

6. **Profile integration** — add `.getProfile` to `APIEndpoint`, create `ProfileService` + a `UserProfile` model, feed `ProfileViewModel`, render real name/email and the avatar via `PLRemoteImage`. Cheapest visible win in the app.
7. **Fix Forgot Password** (§5.2) — remove the `logout()` call now; wire the real endpoint when the backend ships it.
8. **Resolve Google Sign-In** (§5.1) — either add `GIDClientID` + the URL scheme and test end-to-end, or hide the button behind a flag until it is configured. Do not leave a crashing button on the login screen.
9. **Delete or implement `authApple`** (§5.3) — recommend deleting until Apple Sign-In is actually planned.
10. **First unit tests** — `ProductDetailsViewModel` variant logic, then `LoginViewModel` / `SignUpViewModel` validation.

### Phase 2 — Catalog polish (3–5 days, partly blocked on backend)

11. **Home redesign** per Trello #67 — category grid instead of the current layout. Needs the backend to expose categories, or can be derived client-side from `products.category` in the short term.
12. **Catalog pagination** once the backend ships Trello #22. Agree the response shape with the API **before** either side implements.
13. **Search / category filter** on Home.
14. **Realign Figma with code** (Trello #64) so the design file stops being misleading.

### Phase 3 — The purchase flow (2–3 weeks, blocked on backend Phase 2/3)

15. Local cart first (`CartService` + `@Observable` store) so the UI can be built while the backend catches up, then swap the store for the real endpoints.
16. Cart screen, checkout screen, payment method selection, order confirmation.
17. Orders tab (or a Profile sub-screen): order list + order tracking timeline (received → in production → shipped → delivered) — this is the feature the whole proposal is built around.
18. Consider replacing the Library tab with Orders (see open question 2).

### Phase 4 — Product hygiene (ongoing)

19. PT-BR localization via `Localizable.xcstrings`.
20. `.xcconfig`-driven environments (dev/staging/prod base URLs).
21. GitHub Actions: build + test on PR.
22. Crash reporting / analytics before any real user touches it.

---

## 7. Open questions for the owner

1. **Google Sign-In** — do you have the Google Cloud OAuth iOS client ID? Without it the button must come off the login screen. And if social login ships, do you want to add Sign in with Apple (App Store requires it)?
2. **Is the Library / SVG feature still in scope?** Trello #67 says the project drifted toward a laser-cut-file tool when it should be about *selling*. If it is out, the Library tab should be dropped — and Orders is the obvious replacement in that tab slot.
3. **Deployment target** — is 26.1 intentional, or a leftover from starting on the newest SDK?
4. **Language** — should the app be localized to PT-BR before anything else ships? The end users are Brazilian resellers, but every string today is English.
5. **Is this still a course deliverable, or a real product?** It changes whether Phase 4 (localization, environments, CI, crash reporting) is worth doing before Phase 3.
6. **Android** — the third repo is untouched for now. When it restarts, it will need every backend contract decision made in Phase 2/3 to be documented, not just implemented.

---

## 8. Addendum — 2026-09-06 — the Admin tab is in scope

Everything above is a snapshot of 2026-08-30 and is **not** kept up to date; `STATE.md` at the
workspace root is the live document. One scope addition since then changes this app's plan enough to
record here.

**A fourth tab, visible only to admins**, from which the catalog is managed in-app: product list with
search and status filter, create / edit / delete product, quick stock adjust, product image upload.
It is built as a **list of sections** (only "Produtos" active at first) so later admin features drop
in without redesigning navigation.

How visibility is decided:

- The backend adds `role` and `adminOf` to `GET /profile` and to the JWT claims (two levels:
  super admin, admin of every tenant; tenant admin, admin only of their own).
- `UserProfile` (the model created in card #88, §6 step 6 above) gains those fields and derives a
  single **`isAdmin`**; no screen compares role strings by hand.
- Session lives in an `@Observable` store resolved through Swinject, fed at login and at relaunch,
  cleared on logout and account deletion. The role decoded from the JWT is the fallback while
  `GET /profile` is still in flight, so the tab bar does not flicker on launch.
- `AdminCoordinator` follows the existing coordinator pattern; `MainTabCoordinator` registers the tab
  only when `isAdmin`. **Hiding the tab is UI only** — every write is re-authorized server-side.

Watch the tab bar collision: #194 (add Admin tab, Phase 2) touches the same code as #139 (remove
Library) and #140 (add Orders) in Phase 3. Whichever lands first, rebase the other on it.

Trello cards: #189 (Phase 1), #191, #192, #194, #195, #196, #197, #198, #199, #201 (Phase 2),
#203 (Phase 5).
