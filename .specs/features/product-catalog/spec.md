# Product Catalog (Home) Specification

## Problem Statement

A reseller needs to browse what the workshop sells before they can buy anything. Home is the
catalog entry point: a "most popular" carousel plus a full collection grid, sourced from the live
API.

## Goals

- [x] A reseller can see the most popular products and the full collection on launch, with real
      data (Trello #16 seeded 10 products).
- [ ] A reseller can browse by category and search/filter (next — see P2/P3, both blocked on backend).

## Out of Scope

| Feature | Reason |
| --- | --- |
| Cart / "Add to cart" | Blocked on Phase 3 (cart/checkout) — the cart icon fires `showComingSoon()` today. |
| Admin catalog management | Separate concern — the reseller-facing catalog vs. the admin tab (Trello #191–#201) are different screens entirely. |
| Category grid, pagination, search/filter UI | Captured as P2/P3 here since they're real Home requirements, but implementation is blocked on backend endpoints not yet shipped (#106, #22, #110). |

---

## Assumptions & Open Questions

| Assumption / decision | Chosen default | Rationale | Confirmed? |
| --- | --- | --- | --- |
| Catalog modelling | One row per variant (same SKU spans multiple rows by color/dimension) — Home and grid render at the product level, deriving variant info only in Product Details | `.claude/CLAUDE.md` "Backend contract" section states this explicitly; assuming one row per product would misrender the grid | y |
| Category payload shape for the future category grid (P2) | Not assumed — must be agreed with the API side (Trello #106 ↔ #107) before either side implements | Cross-repo contract rule in `.claude/CLAUDE.md` | y |
| Unknown `ProductCategory`/`ProductColor` values from the API | Out of scope for this spec's baseline ACs — covered by `.specs/features/api-decoding-resilience/spec.md`, which this spec depends on | Keeps this spec's ACs from silently duplicating AD-005's concern | y |

**Open questions:** none — all resolved or logged above.

---

## User Stories

### P1: Browse the catalog on Home ⭐ MVP

**User Story**: As a reseller, I want to see the workshop's products on the Home screen so I know
what I can buy.

**Why P1**: without a visible catalog, there's nothing to sell.

**Acceptance Criteria**:

1. WHEN Home loads THEN the system SHALL fetch `GET /products/popular?limit=5` and render it as a
   horizontal "Most popular" carousel.
2. WHEN Home loads THEN the system SHALL fetch `GET /products` and render it as a 2-column
   "Our collection" grid, using `PLProductCard`.
3. WHEN a reseller pulls to refresh THEN the system SHALL re-fetch both endpoints and update the
   screen.
4. WHEN a reseller taps a product card THEN the system SHALL notify the coordinator
   (`homeDidSelectProduct(sku:)`) and never navigate directly from the view.

**Independent Test**: launch the app authenticated, land on Home, see the popular carousel and the
collection grid populated from the live API.

---

### P1: Handle loading, error and empty states ⭐ MVP

**User Story**: As a reseller, I want a clear state when the catalog is loading, failed to load, or
is genuinely empty, instead of a blank screen.

**Why P1**: a catalog screen with no failure handling reads as broken, not empty.

**Acceptance Criteria**:

1. WHILE either catalog request is in flight the system SHALL render `HomeLoadingView`.
2. IF either request fails THEN the system SHALL render `HomeErrorView` with a retry action that
   re-issues the failed request.
3. IF `GET /products` succeeds but returns zero items THEN the system SHALL render an explicit empty
   state, not a blank grid.

**Independent Test**: force a network failure (airplane mode) — see the error state with a working
retry button; restore network and retry — see the grid populate.

---

### P2: Browse by category (blocked on backend)

**User Story**: As a reseller, I want to browse products grouped by category so I don't have to
scroll the whole collection.

**Why P2**: real requirement (Trello #105 design, #106 backend, #107/#108 iOS), but not yet
buildable — the categories endpoint doesn't exist.

**Acceptance Criteria**:

1. WHEN the categories endpoint (#106) exists THEN Home SHALL render a category grid instead of the
   current flat "Our collection" layout.
2. WHEN a reseller taps a category THEN the system SHALL navigate to a filtered product list for
   that category via the coordinator.
3. IF a product's category decodes as `unknown` (see AD-005) THEN it SHALL NOT appear in the
   category grid, but SHALL still appear in the general catalog.

**Independent Test**: not demoable until #106 ships.

---

### P3: Paginate and search the catalog (blocked on backend)

**User Story**: As a reseller with a large catalog to browse, I want pagination and search so the
list stays fast and findable.

**Why P3**: matters once the catalog is large; today's 10 seeded products don't need it yet.

**Acceptance Criteria**:

1. WHEN the catalog pagination shape (#22) is agreed and shipped THEN Home SHALL request pages
   instead of the full collection in one call.
2. WHEN a reseller types in a search field THEN the system SHALL filter using
   `localizedStandardContains()` locally, or a server-side search endpoint (#110) once it exists —
   whichever ships; this AC will be tightened once the backend contract is agreed.

**Independent Test**: not demoable until #22/#110 ship.

---

## Edge Cases

- IF the popular-products request succeeds but the general collection request fails (or vice versa)
  THEN each section SHALL manage its own loading/error state independently — a failure in one SHALL
  NOT blank out the other.
- IF a product in the response has an `unknown` category, status, or color (AD-005) THEN it SHALL
  still render in the general grid with degraded behavior per that spec, never disappear or crash
  the whole screen's decode.

---

## Requirement Traceability

| Requirement ID | Story | Phase | Status |
| --- | --- | --- | --- |
| CAT-01 | P1: popular carousel | Specify | Shipped |
| CAT-02 | P1: collection grid | Specify | Shipped |
| CAT-03 | P1: pull to refresh | Specify | Shipped |
| CAT-04 | P1: coordinator navigation | Specify | Shipped |
| CAT-05 | P1: loading state | Specify | Shipped |
| CAT-06 | P1: error + retry | Specify | Shipped |
| CAT-07 | P1: empty state | Specify | Shipped |
| CAT-08 | P2: category grid | Specify | Pending — blocked on backend #106 |
| CAT-09 | P2: category navigation | Specify | Pending — blocked on CAT-08 |
| CAT-10 | P2: unknown category hidden | Specify | Pending — depends on AD-005 |
| CAT-11 | P3: pagination | Specify | Pending — blocked on backend #22 |
| CAT-12 | P3: search/filter | Specify | Pending — blocked on backend #110 |

**ID format:** `CAT-NN`.

**Coverage:** 12 total, 7 shipped, 5 blocked on backend work not yet started ⚠️.

---

## Success Criteria

- [x] Home shows a real, live catalog with working loading/error/empty states.
- [ ] Category browsing replaces the flat grid (CAT-08/09).
- [ ] Pagination and search land once the backend contracts are agreed (CAT-11/12).
