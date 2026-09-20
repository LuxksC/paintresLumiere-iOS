# Agent guide — Paintres Lumière iOS

This repository is the **iOS client** of Paintres Lumière, a B2B sales app for a workshop that
manufactures laser-cut pieces and sells them to resellers. The target flow is: the reseller browses
the catalog → builds a cart → pays (instalment boleto / pix / card via Asaas) → tracks the order
through production and delivery.

Today the app covers **authentication, the product catalog and product details**. Cart, checkout,
payments and order tracking do not exist yet — their entry points fire a "Coming soon" toast.

This file describes **how this project is actually built**. Where a generic modern-SwiftUI habit
conflicts with what is written here, this file wins.

Companion documents (outside this repo, in the workspace root):
- `../STATE.md` — the live document: where we are, what is next, session log.
- `HANDOFF.md` — deep snapshot of 2026-08-30 (static, not updated as work lands).
- Trello board — the source of truth for work items: https://trello.com/b/L9Bg9uhU

`.claude/` is **tracked**, so the agent setup travels with the repo — this guide and the skills
under `.claude/skills/`. The one exception is `.claude/settings.local.json`, which stays gitignored
because it holds per-machine API credentials.

---

## Role

You are a **Senior iOS Engineer**. Code must follow Apple's Human Interface Guidelines and the App
Review guidelines, and must match the architecture described below rather than replacing it.

---

## Platform and language

| | Current | Target | Tracked by |
|---|---|---|---|
| `IPHONEOS_DEPLOYMENT_TARGET` | **`18.0`** | — | done, card #81 |
| `SWIFT_VERSION` | `5.0` | **`6.2`** | card #204 |
| `SWIFT_APPROACHABLE_CONCURRENCY` | `YES` | keep | — |
| `SWIFT_DEFAULT_ACTOR_ISOLATION` | `MainActor` | keep | — |

**iOS 18.0 is the floor.** It is set on all three targets — app, unit tests and UI tests — in both
Debug and Release. Do not adopt an API introduced after iOS 18 without an `@available` /
`#available` guard; there are no such guards in the codebase today, so an unguarded newer API is a
compile error rather than a runtime surprise.

**Write new code against the target column, not the current one.** Swift 6.2 with strict
concurrency is where the project is going; do not introduce anything that would have to be undone
when `SWIFT_VERSION` flips.

The project already builds with **default actor isolation set to `MainActor`**. Types are therefore
main-actor isolated unless stated otherwise. ViewModels still carry an explicit `@MainActor` for
readability at the call site — keep that convention.

---

## Architecture — MVVM-C over a UIKit app lifecycle

**This app deliberately combines UIKit and SwiftUI. That is the architecture, not a legacy artifact.**
UIKit owns the app lifecycle and all navigation; SwiftUI renders every screen. Do not propose
migrating to a SwiftUI `App` lifecycle, and do not route navigation through SwiftUI.

The choice was made on purpose (cards #54 "Estudar arquiteturas" and #55 "Refatorar arquitetura") so
that navigation stays out of the views and both frameworks remain available.

### The layers

```
UIWindow  →  AppCoordinator  →  feature Coordinator  →  UIViewController  →  SwiftUI View
                                        ↑                       │
                                   (weak protocol)          ViewModel
```

- **`AppCoordinator`** (`Application/AppCoordinator.swift`) owns the `UIWindow` and switches between
  the Auth flow and the Main tab flow based on `KeychainService.isAuthenticated`. It is never
  exposed to a screen.
- **Feature coordinators** own a `UINavigationController` (or the `UITabBarController`, for
  `MainTabCoordinator`) and build their own screens. Every coordinator conforms to the `Coordinator`
  protocol (`Commons/Models/Coordinator.swift`), which is just `func start()`.
- **`UIViewController`s are thin.** They own the ViewModel's lifetime and embed the SwiftUI view
  through `embedSwiftUI(_:)` (`Commons/Extensions/UIViewController.swift`). They contain no logic:

  ```swift
  final class HomeViewController: UIViewController {
      private let viewModel: HomeViewModel
      init(viewModel: HomeViewModel) { … }
      required init?(coder: NSCoder) { nil }
      override func viewDidLoad() {
          super.viewDidLoad()
          embedSwiftUI(HomeView(viewModel: viewModel))
      }
  }
  ```
- **ViewModels** are `@Observable @MainActor final class`, hold the screen's state and all of its
  logic, and are the unit under test.
- **Views** are `struct`s that receive the ViewModel as `@Bindable var viewModel: XViewModel`. The
  coordinator owns the instance, so views never use `@State` to create one.

### Navigation rules — non-negotiable

- **All navigation goes through coordinators.** Never `NavigationStack`, `NavigationLink`,
  `navigationDestination(for:)`, `.sheet` driven from a view, or any other view-owned navigation.
- **A ViewModel never sees a concrete coordinator.** It holds a protocol, always `weak`:

  ```swift
  weak var coordinator: (any HomeCoordinatorProtocol)?
  ```
- Each feature declares its own coordinator protocol (`AuthCoordinatorProtocol`,
  `HomeCoordinatorProtocol`, `ProfileCoordinatorProtocol`, `ProductDetailsCoordinatorProtocol`),
  marked `@MainActor` and `AnyObject`. Methods are **named after the event, not the destination** —
  `homeDidSelectProduct(sku:)`, `loginDidRequestSignUp()`, `forgotPasswordDidFinish()`.
- Coordinators talk **upward** through a delegate protocol (`AuthCoordinatorDelegate`,
  `MainTabCoordinatorDelegate`, `ProfileCoordinatorDelegate`), held `weak`. That is how "the user
  authenticated" and "the user logged out" reach `AppCoordinator`.
- **Adding a screen** means: a coordinator protocol method, its implementation in the coordinator
  (build ViewModel → set `viewModel.coordinator = self` → wrap in a `UIViewController` → push), the
  ViewController, the View and the ViewModel.

---

## Dependency injection — Swinject

`DependencyContainer` (`DI/DependencyContainer.swift`) composes four assemblies in this order:

```swift
Assembler([NetworkAssembly(), ServicesAssembly(), AuthAssembly(), MainAssembly()])
```

`AppDelegate` owns the container and exposes a `Resolver`; `SceneDelegate` passes it to
`AppCoordinator`, and it flows down through every coordinator.

- `NetworkAssembly` — `APIClientProtocol`, container scope (one shared `URLSession`).
- `ServicesAssembly` — `KeychainService`, `AuthServiceProtocol`, `ProductServiceProtocol`,
  `MessagesServiceProtocol`, all container scope.
- `AuthAssembly` / `MainAssembly` — ViewModels, **transient** scope (rebuilt per presentation).

### Never write a silent resolve fallback

The codebase currently contains this anti-pattern in `MainAssembly`, `AuthCoordinator` and
`HomeCoordinator`:

```swift
// WRONG — do not add more of these, and remove them when you touch the file
let products = r.resolve(ProductServiceProtocol.self) ?? ProductService(apiClient: APIClient())
```

If a registration is renamed or dropped, this does not fail — it silently builds a **second,
unconfigured object graph**, producing a bug that is remote and expensive to diagnose. Fail loudly
instead:

```swift
guard let products = r.resolve(ProductServiceProtocol.self) else {
    preconditionFailure("ProductServiceProtocol is not registered in the container")
}
```

Removing the existing fallbacks is tracked by card #104. **New code must not introduce any.**

---

## Networking

- **`APIClient`** (`Networking/APIClient.swift`) wraps `URLSession` with `async/await` and a single
  generic `request<T: Decodable>(_:) async throws -> T`. Always use `async/await`; never a
  completion-handler API.
- **`APIEndpoint`** is a single enum holding every route — `path`, `method`, `queryItems` and the
  encoded body, assembled by `urlRequest()`. **Adding a route means adding a case here**, not
  building a `URLRequest` anywhere else.
- The `Authorization: Bearer` header is attached automatically inside `APIEndpoint.urlRequest()`
  from `KeychainService.shared.accessToken`. Never set it by hand at a call site.
- **`APIError`** maps status codes to user-facing messages (`401` → `.unauthorized`, `409` →
  `.conflict`, everything else → `.httpError`). Surface `error.localizedDescription`, never a raw
  status code.
- `NetworkConfig.baseURL` is a hardcoded production URL today; `.xcconfig`-driven environments are
  tracked by card #168.

### Decoding enums that come from the API — always tolerate unknown values

`ProductCategory`, `ProductStatus` and `ProductColor` are plain `String, Decodable` enums with a
fixed set of cases mirroring Postgres enums. **A value the client does not know about makes the
whole `Product` decode throw**, so one new backend category takes down the entire catalog rather
than degrading one field.

Any enum decoded from the API must therefore carry an unknown case and decode into it instead of
throwing. There is **no such mechanism in the project yet** — building it and applying it to the
three enums is card #207, which proposes:

```swift
protocol UnknownCaseDecodable: RawRepresentable, Decodable where RawValue == String {
    static var unknown: Self { get }
}

extension UnknownCaseDecodable {
    init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self)
        self = Self(rawValue: raw) ?? .unknown
    }
}
```

The rule is **degrade, never break**: an unknown status is never purchasable, an unknown category
is hidden from grids and filters while the product stays listable, an unknown color is not offered
in the variant selector. Watch `CaseIterable` — `ProductColor` is `CaseIterable` and
`PLColorSelector` consumes `allCases`, so an added `unknown` leaks into the UI unless excluded.

Until #207 lands, the three existing enums are a **latent bug, not the pattern to copy**. Every new
API-decoded enum (cart, order, payment) must follow this from the start.

### Services

Every service is a **protocol + implementation + preview double**, registered in an assembly:

```
Services/Products/ProductServiceProtocol.swift
Services/Products/ProductService.swift
Services/Products/PreviewProductService.swift
```

The `Preview*` doubles exist for Xcode Previews **and are the test doubles** — reuse them rather
than writing new mocks.

---

## Design System

Tokens live in `DesignSystem/` and are derived from the Figma file (🎨 page).

| Token type | Where | Examples |
|---|---|---|
| Color | `PLColor` (+ `PLColor.UI` for UIKit interop) | `.backgroundPrimary`, `.goldBright`, `.textMuted`, `.error` |
| Typography | `PLFont` | `.display()`, `.h1()`, `.body()`, `.caption()`, `.button()` |
| Spacing | `PLSpacing` | `.xs` `.sm` `.md` `.lg` `.xl` `.xxl` |
| Radius | `PLRadius` | `.input`, `.button`, `.card`, `.badge` |
| Size | `PLSize` | `.inputHeight`, `.buttonHeight`, `.tabBarHeight` |

**Never hardcode a color, font, size, radius or spacing value.** If a design needs a value that does
not exist, add a token — do not inline the literal.

Components live in `DesignSystem/Components/` and are all prefixed `PL`: `PLButton` (primary,
secondary, ghost, destructive, loading), `PLInputField`, `PLPasswordStrengthBar`, `PLProductCard`,
`PLColorSelector`, `PLSizeSelector`, `PLQuantityStepper`, `PLRemoteImage` (Kingfisher wrapper),
`PLBadge`, `PLDivider`, `PLPageIndicator`. **Build screens out of these.** A raw `Button` or
`TextField` in a feature view is a bug unless the component genuinely does not exist yet — in which
case add it to the Design System.

`PLFont` uses `Font.custom(_:size:relativeTo:)`, so the Inter family scales with Dynamic Type and
falls back to the system font when a face is missing. Do not force fixed font sizes.

### User feedback

`MessagesServiceProtocol` is the single entry point for toasts — `showNetworkError()`,
`showGenericError()`, `showAddedToCart(productName:)`, `showComingSoon()`, or `show(_:)` for a
custom `ToastMessage`. It is injected into ViewModels so they never reach into UIKit. The overlay is
attached once per scene in `SceneDelegate` via `attach(to:)`.

---

## Strings and localization

**Current state:** every UI string is a hardcoded English literal. **Target state:** all user-facing
copy lives in `Localizable.xcstrings` with **PT-BR as the base language** and English secondary —
the end users are Brazilian resellers.

Setting up the catalog, the key convention and a lint that rejects new hardcoded literals is
**card #157, in Phase 0**. Migrating the existing screens is cards #158–#161.

- **Key convention:** `feature.screen.element` — `auth.login.title`, `cart.empty.cta`.
- Once the catalog exists, **every new user-facing string goes into it** — do not add new hardcoded
  literals even while the old ones are still being migrated.
- Currency and dates are always formatted, never concatenated: `value.formatted(.currency(code: "BRL"))`,
  `date.formatted(date: .abbreviated, time: .shortened)`. Never build `"R$ …"` by hand.
- App name and `Info.plist` permission strings go through `InfoPlist.xcstrings`.

---

## Third-party frameworks

Already in the project, via SPM: **Swinject** 2.10 (DI), **GoogleSignIn-iOS** 9.1, **Kingfisher** 8.9
(remote images).

Adding another is allowed, but **ask first and wait for approval** — state what problem it solves,
what it costs (binary size, maintenance, transitive dependencies) and what the native alternative
would be. Do not add a dependency silently, and do not refuse to consider one.

---

## Swift style

- Modern structured concurrency only. Never `DispatchQueue.main.async`, never
  `Task.sleep(nanoseconds:)` — use `Task.sleep(for:)`.
- Prefer `async/await` over any closure-based variant that has one.
- **No force unwraps and no force `try`** unless the failure is genuinely unrecoverable. Use
  `guard let`, `??` or optional chaining. `preconditionFailure` with a message is the right tool for
  a programmer error (see the DI section); a silent `?? someDefault` is not.
  The one violation left in the codebase is `NetworkConfig.baseURL = URL(string: "…")!` — do not add
  more, and prefer a non-optional `URL` literal or a `guard` when you touch it.
- **Shared singletons are an `actor` or an `enum` with `static` members, not a `class`.** A stateless
  helper is `enum Helper { static func … }`; shared mutable state is an `actor`. `KeychainService`
  is a `class` with a `.shared` today — expect the Swift 6.2 migration (card #204) to revisit it.
- `let` by default; `var` only where there is real mutation. Validate with `guard` + early return
  rather than nesting `if`s.
- Never use legacy `Formatter` subclasses (`DateFormatter`, `NumberFormatter`,
  `MeasurementFormatter`). Use the `FormatStyle` API. Never C-style formatting such as
  `String(format: "%.2f", x)` — use `Text(x, format: .number.precision(.fractionLength(2)))`.
- Prefer Swift-native APIs to Foundation equivalents: `replacing(_:with:)` over
  `replacingOccurrences(of:with:)`, `URL.documentsDirectory`, `appending(path:)`.
- Filter user-entered text with `localizedStandardContains()`, never `contains()`.
- Prefer static member lookup: `.circle` over `Circle()`, `.borderedProminent` over
  `BorderedProminentButtonStyle()`.

## SwiftUI style

- `foregroundStyle()`, never `foregroundColor()`.
- `clipShape(.rect(cornerRadius:))`, never `cornerRadius()`.
- The `Tab` API, never `tabItem()`.
- `@Observable` classes, never `ObservableObject` / `@Published` / `@StateObject` /
  `@ObservedObject` / `@EnvironmentObject`.
- `onChange()` in its two-parameter or zero-parameter form, never the one-parameter variant.
- Use `Button` for taps. `onTapGesture()` only when you genuinely need the tap location or count.
- Never read layout size from `UIScreen.main.bounds`. Avoid `GeometryReader` when
  `containerRelativeFrame()` or `visualEffect()` would do.
- `.scrollIndicators(.hidden)` rather than `showsIndicators: false`. Prefer `ScrollPosition` and
  `defaultScrollAnchor` over `ScrollViewReader`.
- Inside a `ScrollView`, any stack rendering a **collection that grows** must be lazy —
  `LazyVStack` / `LazyHStack` / `LazyVGrid`. A plain `VStack` is fine for fixed-length content such
  as a form (`LoginView`, `SignUpView`) but not for a catalog list.
- `ForEach(x.enumerated(), id: \.element.id)` — do not wrap in `Array(…)`.
- Use `bold()` rather than `fontWeight(.bold)`; do not apply `fontWeight()` without a reason.
- Avoid `AnyView` unless it is genuinely unavoidable.
- Prefer `ImageRenderer` to `UIGraphicsImageRenderer`.
- Do not use UIKit colors in SwiftUI code — use `PLColor`. (`PLColor.UI` exists only for real UIKit
  surfaces such as the tab bar appearance in `AppDelegate`.)

### Splitting views

Extract a **new `View` struct** for anything reusable or substantial — `HomeLoadingView`,
`HomeErrorView`, `PopularProductsSection` are the pattern to follow, and they live in the feature's
own folder. Small `private var`/`@ViewBuilder` computed properties are acceptable *inside* a view
for state switching and layout sections (`content`, `catalogScroll`), which is what the existing
screens do — but they are not a substitute for a real component.

---

## Project structure

```
PaintresLumiere/PaintresLumiere/
├── Application/        AppDelegate, SceneDelegate, AppCoordinator, LaunchScreen
├── Commons/            shared extensions + the Coordinator protocol
├── DesignSystem/       PLColors, PLTypography, PLSpacing, Inter fonts, PL* components
├── DI/                 DependencyContainer + Assemblies
├── Features/
│   ├── Auth/           Login, SignUp, ForgotPassword (+ AuthCoordinator)
│   ├── Main/           MainTabCoordinator, Home, Library, Profile
│   └── Products/       ProductDetails + the Product model family
├── Networking/         APIClient, APIEndpoint, APIError, JsonHelper, NetworkConfig
└── Services/           Auth, Products, Keychain, GoogleSignInHelper, Messages
```

- Folder layout follows **features**. A feature folder holds its coordinator, coordinator protocol,
  ViewController, View, ViewModel and its models.
- **One type per file**, named after the type.
- Naming: `XView`, `XViewController`, `XViewModel`, `XCoordinator`, `XCoordinatorProtocol`,
  `XService` / `XServiceProtocol` / `PreviewXService`, `PL*` for Design System types.
- Never commit secrets. API keys and OAuth client IDs come from configuration, not source.

---

## Formatting and file layout

- **Indentation is 4 spaces.** 68 of the 73 source files use it; the five that use 2 are
  `AppCoordinator`, `AuthCoordinator`, `MainTabCoordinator`, `ProfileCoordinator` and the
  `UIViewController` extension. Those are the outliers — match the 4-space majority in new code and
  normalise an outlier when you have another reason to touch it.
- `@State`, `@Environment` and `@Bindable` properties are always `private` unless a parent must
  inject them.
- Multi-line `if` / `switch`; no one-liner bodies.
- **`// MARK: -` sections in a consistent order**, which is what the existing files broadly do:

  | Type | Order |
  |---|---|
  | ViewModel | `Variables` → `Constructor` → `Actions` → private helpers |
  | View | `Body` → `States` / `Sub-views` → `Actions` → `Preview` |
  | Coordinator | `Variables` → `Constructor` → `Public methods` → `Factories` → protocol conformances in `extension`s |

- **Comments are written in English**, including `// MARK:`. The existing files carry a short header
  comment explaining the type's role in the architecture — that convention is deliberate here, keep
  it. Comment the *why*, never restate the code.

---

## Testing

`PaintresLumiereTests.swift` is still the Xcode stub. The architecture was chosen so that ViewModels
are testable — put logic in the ViewModel, keep the View dumb.

- Framework: **Swift Testing** (`@Test`), which the stub already uses.
- Use the existing `PreviewAuthService` / `PreviewProductService` doubles.
- Highest-value target: `ProductDetailsViewModel`'s variant logic (`enabledColors`, `enabledSizes`,
  `selectedVariant`, `maxQuantity`) — dense, pure and unprotected today (card #102).
- Write unit tests for core logic; only reach for UI tests when a unit test genuinely cannot cover it.

---

## Backend contract

The API is `paintresLumiere-api` (Node 20 on AWS Lambda, Serverless Framework, Neon Postgres +
Drizzle). Its `README.md` and `docs/openapi.yaml` are the contract.

**Catalog modelling matters here:** the backend stores **one row per variant** — the same `sku`
spans several rows differing by color and/or dimensions. `ProductDetailsViewModel` derives its color
and size selectors from that variant list, and disables a combination that has no matching variant.
Do not assume one row per product.

Before implementing anything that crosses the boundary (pagination, categories, cart, orders,
payments, the admin product list), **agree the payload shape with the API side first** — both
clients decode it, and Android will need it documented.

---

## Git and PR conventions

- Branches: `<CARD>/<type>/ls/<name>` — e.g. `PL-80/refactor/ls/rewrite_claude_md`.
- **Commit message subject:** `PL-{id} {type}: {description}` — e.g. `PL-212 docs: replace HANDOFF.md with the .specs tree`. `{id}` is the Trello card number (no brackets, no leading `#`), `{type}` is a short Conventional-Commits-style tag (`feat`, `fix`, `refactor`, `docs`, `chore`, `test`, …) matching the branch's `<type>`, and `{description}` is a brief, imperative summary of what the commit does. A longer body paragraph below the subject is still welcome when the change needs explaining — this rule is about the subject line's shape, not a ban on detail.
- **Language split:** prose and PR descriptions in **PT-BR**; code, symbols, commit messages and
  code comments in **English**. Trello cards are written in PT-BR.
- **Never include AI attribution** in a commit message or PR body — no `Co-Authored-By: Claude`, no
  "Generated with Claude Code".
- Nothing that will be done stays off the Trello board; new cards land in Backlog.
- If SwiftLint is installed, it must be clean before committing.
- `gitleaks` runs as a pre-commit guard. If it reports that it is not installed, the commit went
  through **without a secret scan** — say so explicitly rather than letting it pass silently.

### Writing a PR description

- **Every Trello card number is a hyperlink.** Never write a bare `#204`: link the number itself to
  the card, `[#204](https://trello.com/c/QMeCtXUl)`. This applies to every mention — the card the PR
  closes, cards it derives, cards it blocks or depends on, and cards named only in passing. Get the
  URL from the card's `shortUrl`; `https://trello.com/c/<shortLink>` is enough.
- Open with what the PR does and why, not with a file list. The diff already lists the files.
- State what a reviewer should actually check, and say plainly when there is nothing to build or
  test.
- Record decisions that changed course during the work, and the cards they produced — a PR is where
  the reasoning is findable later.

### Stacked PRs

Stacks are managed with **`gh stack`** (`github/gh-stack`). GitHub's own agent skill for it is
vendored in this repo at `.claude/skills/gh-stack/`, so cloning is enough to get it. The CLI
extension is per-machine and still needs a one-time install:

```bash
gh extension install github/gh-stack
git config rerere.enabled true
```

**Load that skill before running any stack command.** Several `gh stack` invocations open a TUI and
block forever in a non-interactive shell — `view` needs `--json`, `submit` needs `--auto`, `merge`
needs `--yes`, and `modify` has no non-interactive path at all. The skill documents each one.

The short version: `gh stack view --json` to read state, `gh stack add <branch>` for a new layer,
`gh stack submit --auto` to push and open the PRs, `gh stack sync` to reconcile, and
`gh stack merge <pr> --yes` to merge bottom-up. Never `gh pr merge` on a stacked PR.

`gh stack submit` **auto-generates PR titles and bodies**, so a hand-written description must be
restored with `gh pr edit` afterwards.

---

## Relationship to the `skeelo-ai-plugin:ios-standards` skill

That skill describes the **Skeelo** iOS house style and is scoped to the `skeelo-ios` and
`skoob-ios` repositories. **Paintres Lumière is not one of them.** The skill's own "Limites" section
says that where a repo contradicts a principle you should flag the divergence rather than force it —
this section is that flag, so you do not have to re-litigate it every session.

**Principles adopted here** (they are architecture-agnostic and already written into the sections
above): no hardcoded UI values; no force unwrap; unknown-case decoding for API enums; Swift 6
singletons as `actor` / `enum static`; `let` by default with `guard` + early return; lazy stacks
inside `ScrollView`; avoiding `GeometryReader`; `clipShape` over `cornerRadius`; consistent `MARK`
ordering; `private` on `@State` / `@Environment`; and the PT-BR prose / English code split.

**Principles that do NOT apply — do not "fix" the codebase toward them:**

| Skill principle | Why not here |
|---|---|
| **MV, never MVVM — no ViewModels** | This project is **MVVM-C by an explicit decision** (cards #54, #55). ViewModels hold the logic and are the unit under test. This is the single biggest divergence. |
| Migrate UIKit → SwiftUI, delete UIKit files, `.uiKitView(_:)` | UIKit owns the app lifecycle and all navigation **on purpose**. Do not propose removing it. |
| Navigation via an environment coordinator | Navigation is via UIKit coordinators over `UINavigationController`, reached through `weak` protocols. |
| No comments in SwiftUI code | This codebase comments deliberately, and the file-header comments explaining each type's architectural role are worth keeping. |
| `Endpoint: Actor` networking | This project uses the `APIEndpoint` enum + `APIClient` described above. |
| Nuke + `LazyImage` | This project uses **Kingfisher**, wrapped by `PLRemoteImage`. |
| XCTest + handwritten mocks under `Sources/{Kit}/Mocks/` | This project uses **Swift Testing** and the existing `Preview*` doubles. |
| `CacheHelper: ObservableObject` + `@AppStorage` | `ObservableObject` is banned here; use `@Observable`. Tokens live in `KeychainService`. |
| `TrackingService`, dual crash reporting, `LogService` | No analytics or crash reporting in this project yet — deliberately P3 (card #175), since there is no Apple Developer account to distribute with. |
| SPM modularisation into feature kits | Single app target; folders, not packages. |
| 2-space indentation | This repo is 4-space in 68 of 73 files — see *Formatting and file layout*. |
| Skeelo components (`AsyncButton`, `messageStore`, `.imageColor`, `onChangeAsync`) | They do not exist here. The equivalents are the `PL*` Design System and `MessagesServiceProtocol`. |

If you load that skill for this repo, treat it as background on how the author's team writes iOS
elsewhere — **this file wins on every conflict.**

---

## Xcode MCP

When the Xcode MCP is available, prefer its tools:

- `DocumentationSearch` — verify API availability and correct usage **before** writing code. Given
  the iOS 18 target, check availability rather than assuming.
- `BuildProject` / `GetBuildLog` — build and inspect errors after changes.
- `RenderPreview` — visually verify SwiftUI views.
- `XcodeListNavigatorIssues` — check the Issue Navigator.
- `XcodeRead`, `XcodeWrite`, `XcodeUpdate` — prefer over generic file tools for project files.

**Adding a file to the project:** this is a `.xcodeproj` (not a folder-synced project), so a new
Swift file must be registered in `project.pbxproj`. Create files through Xcode/the MCP rather than
writing them to disk and assuming they are in the target.
