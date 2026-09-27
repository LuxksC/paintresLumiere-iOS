# STATE

Project memory for `paintresLumiere-ios` under the `tlc-spec-driven` skill. Scoped to this repo
only — the cross-repo live document is `../STATE.md` (workspace root); read that one for
backend/Android status, the current Trello cycle, and owner-level decisions. This file's
`## Decisions` log records iOS-specific, project-level conventions; `## Handoff` is the pause/resume
snapshot for this repo.

This file replaces `HANDOFF.md` (deleted 2026-09-20). `HANDOFF.md` was a static, one-time snapshot;
this file — plus `.specs/features/` — is the living replacement, updated as work lands instead of
frozen in time.

---

## Decisions

### AD-001
- **Decision**: MVVM-C over a UIKit app lifecycle, with every screen rendered in SwiftUI and hosted via `embedSwiftUI(_:)`. Navigation goes only through coordinators, reached from ViewModels as `weak` protocols.
- **Reason**: keeps navigation out of the views and keeps both UIKit and SwiftUI available, decided deliberately (Trello #54 "Estudar arquiteturas", #55 "Refatorar arquitetura") rather than inherited by accident.
- **Trade-off**: gives up `NavigationStack`/`navigationDestination` and an all-SwiftUI app lifecycle — every new screen costs a coordinator method + ViewController in addition to the View/ViewModel.
- **Scope**: whole app — every feature.
- **Date**: 2025 (pre-dates this file; recorded retroactively from `.claude/CLAUDE.md` and `HANDOFF.md` §3).
- **Status**: active.

### AD-002
- **Decision**: Swinject DI via four assemblies (`NetworkAssembly`, `ServicesAssembly`, `AuthAssembly`, `MainAssembly`), composed in that order. Network/Services are container-scoped (one shared instance); Auth/Main ViewModels are transient (rebuilt per presentation).
- **Reason**: one shared `URLSession`/services graph, but a fresh ViewModel per screen presentation so state doesn't leak across visits.
- **Trade-off**: a dropped or renamed registration is a runtime concern, not a compile-time one — hence AD-006 below.
- **Scope**: whole app.
- **Date**: pre-dates this file.
- **Status**: active.

### AD-003
- **Decision**: `IPHONEOS_DEPLOYMENT_TARGET = 18.0` (lowered from `26.1`).
- **Reason**: `26.1` excluded essentially the entire installed iPhone base — indefensible for a real reseller-facing app, even coming from a course project that started on the newest SDK.
- **Trade-off**: no API introduced after iOS 18 without an explicit `@available`/`#available` guard — there are none in the codebase today, so an unguarded newer API is a compile error, not a runtime surprise.
- **Scope**: whole app — all three targets (app, unit tests, UI tests), both Debug and Release.
- **Date**: 2026-09-20 (Trello #81, shipped — `PL-81` commit `9455e45`).
- **Status**: active.

### AD-004
- **Decision**: migrate to `SWIFT_VERSION = 6.2` with strict concurrency, building on the `SWIFT_APPROACHABLE_CONCURRENCY = YES` / `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` settings already in place.
- **Reason**: ViewModels are already `@Observable @MainActor`, coordinator protocols are already `@MainActor`, and networking is already `async/await` — half the concurrency migration is already done by convention, so finishing it now is cheaper than it will ever be again.
- **Trade-off**: any strict-concurrency error surfaced by the flip must be fixed for real (`Sendable` conformance, actor isolation) — never silenced with `@unchecked Sendable` or `nonisolated(unsafe)` without a written justification.
- **Scope**: whole app.
- **Date**: target declared 2026-09-06 (`.claude/CLAUDE.md` rewrite, card #80); shipped 2026-09-20 (card #204, branch `PL-204/refactor/ls/migrate_to_swift_6_2`).
- **Status**: active, shipped. `KeychainService` was evaluated for actor conversion during this work and kept as a `Sendable` class instead — see `.claude/CLAUDE.md`'s Swift style section for the reasoning (an actor would force `APIEndpoint.urlRequest()`'s synchronous token read to become `async`).

### AD-005
- **Decision**: every enum decoded from the API must tolerate an unknown case instead of throwing — degrade the one affected field, never fail the whole decode. Concretely: an `UnknownCaseDecodable` protocol with an `unknown` case, applied first to `ProductCategory`, `ProductStatus`, `ProductColor`.
- **Reason**: today these three are plain `String, Decodable` enums with a closed case set. A single unrecognized value from the backend throws during `Product` decoding, which fails the *entire* catalog array — one new category or color takes down Home for every product, not just the one that changed. This stopped being hypothetical once real catalog data (#16) and admin-created products (#196) entered the picture.
- **Trade-off**: every consumer of a `CaseIterable` API enum (`PLColorSelector` on `ProductColor.allCases`, category grids/filters) must explicitly exclude `.unknown` or it leaks into the UI.
- **Scope**: `Networking/`, `Features/Products/Models/`, and every future API-decoded enum — cart, order, payment (Phases 3–4).
- **Date**: identified 2026-09-06 during the `.claude/CLAUDE.md` rewrite; mechanism not yet built (Trello #207).
- **Status**: active (decided, execution pending). See `.specs/features/api-decoding-resilience/spec.md`.

### AD-006
- **Decision**: a Swinject resolve failure must fail loudly (`guard let ... else { preconditionFailure(...) }`), never fall back silently to a second, unconfigured object graph (`resolver.resolve(X.self) ?? X(apiClient: APIClient())`).
- **Reason**: the silent fallback pattern already present in `MainAssembly`, `AuthCoordinator` and `HomeCoordinator` turns a dropped/renamed registration into a remote, expensive-to-diagnose bug instead of an immediate crash pointing at the cause.
- **Trade-off**: a misconfigured container now crashes instead of degrading — accepted, because degrading here means silently running against the wrong object graph.
- **Scope**: `DI/` and every coordinator/assembly resolve call.
- **Date**: existing violations documented 2026-09-06; removal tracked as Trello #104, not yet done.
- **Status**: active (decided, execution pending — do not add new fallbacks in the meantime).

### AD-007
- **Decision**: `Localizable.xcstrings` ships with **PT-BR as the base language**, English as secondary, key convention `feature.screen.element`.
- **Reason**: end users are Brazilian resellers; every string today is an English literal, which is backwards for the actual audience.
- **Trade-off**: base-language-as-PT-BR is the opposite of the typical Xcode default (English base) — anyone unfamiliar with the decision will assume it's a mistake; it isn't.
- **Scope**: whole app, going forward — new code must use the catalog even while old screens are still being migrated (Trello #158–#161).
- **Date**: infrastructure card (#157) deliberately pulled from Phase 5 into Phase 0 on 2026-09-06, precisely so new code stops adding to the hardcoded-string debt. Not yet built.
- **Status**: active (decided, execution pending).

---

## Handoff

- **Feature**: none in progress — #204 (Swift 6.2 migration) is committed on its own branch, not yet merged.
- **Phase / Task**: N/A — between cards. Trello Phase 0 (card #178) is the active phase; see `../STATE.md` §5–6 for full board state.
- **Completed**: #204 Swift 6.2 + strict concurrency migration, all six build configs, zero errors/warnings, verified with `RunAllTests` and `RenderPreview` on Login/Home/ProductDetails (commit `73ae9ba`, not yet pushed/PR'd); #212 this repo's `.specs/` tree + `/check-project-state` command (replacing `HANDOFF.md` + `/handoff-check`, merged via PR #6); #81 deployment target → iOS 18 (`PL-81`); #80 `.claude/CLAUDE.md` rewritten for the real architecture (`PL-80`); #16 catalog seeded with 10 real products; backend #114/#115/#205 shipped the API-proxied image upload + processing pipeline (images are now client-readable, relevant to `PLRemoteImage`/Kingfisher even though this repo didn't change).
- **In-progress**: none.
- **Next step**: push `PL-204/refactor/ls/migrate_to_swift_6_2` and open its PR (pending Lucas's go-ahead), then pick up #157 (Localizable.xcstrings infra, AD-007) — unblocked, iOS-only, Phase 0 · P1. Separately, the commit-message-convention edit to `.claude/CLAUDE.md` is stashed on `main` (`git stash list`), waiting for Lucas to commit it himself.
- **Blockers**: none for #157. Owner-action items blocking *other* Phase 0/1 work: #74 Asaas sandbox account (blocks Phase 4 payments — briefly moved to DONE on 2026-09-20 and moved back, still open), #77 Google Cloud OAuth iOS client ID (blocks #87 Google Sign-In, see `.specs/features/google-sign-in/spec.md`), #95 AWS SES provisioning (blocks the password-reset flow), #163 Apple Developer account (blocks device distribution and Apple Sign-In verification, see `.specs/features/apple-sign-in/spec.md`).
- **Uncommitted files**: `PaintresLumiere/.DS_Store` and the Xcode `UserInterfaceState.xcuserstate` (pre-existing repo-hygiene noise, tracked by Trello #84) remain unstaged/untouched.
- **Branch**: `PL-204/refactor/ls/migrate_to_swift_6_2`.
