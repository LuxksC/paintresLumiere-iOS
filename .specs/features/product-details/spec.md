# Product Details Specification

## Problem Statement

A reseller needs to inspect one product closely before buying: photos, price, description, and —
because the backend stores one row per variant — the correct color/size combination for what's
actually in stock. This is the most logically dense screen in the app today.

## Goals

- [x] A reseller can view a product's full detail, with variant-aware color/size selection that
      respects real stock per variant.
- [ ] The Buy / Add-to-cart actions do something real (blocked on Phase 3 — cart doesn't exist yet).

## Out of Scope

| Feature | Reason |
| --- | --- |
| Cart / checkout | Buy and Add-to-cart currently fire `showComingSoon()` — real behavior is Phase 3, a separate future spec. |
| Admin product editing | Different screen entirely (Trello #196/#197, the Admin tab). |

---

## Assumptions & Open Questions

| Assumption / decision | Chosen default | Rationale | Confirmed? |
| --- | --- | --- | --- |
| Variant modelling | The same SKU spans multiple rows differing by color and/or dimensions; `ProductDetailsViewModel` derives `enabledColors`/`enabledSizes` from the live variant list rather than assuming every color × size combination exists | `.claude/CLAUDE.md` "Backend contract" section; disabling a combination with no matching variant is required, not optional | y |
| Unknown `ProductColor` values | Out of scope for this spec — covered by `.specs/features/api-decoding-resilience/spec.md` (AD-005); `PLColorSelector`'s `allCases` consumption must exclude `.unknown` once that lands | Keeps this spec focused on variant-selection logic, not decoding resilience | y |

**Open questions:** none — all resolved or logged above.

---

## User Stories

### P1: View product detail and select a valid variant ⭐ MVP

**User Story**: As a reseller, I want to see a product's photos, price and description, and pick a
color/size that's actually available, so I know exactly what I'd be ordering.

**Why P1**: this is the screen that turns "browsing" into "deciding to buy."

**Acceptance Criteria**:

1. WHEN a reseller opens a product THEN the system SHALL render an image carousel with a page
   indicator (`PLPageIndicator`), name, price, and description.
2. WHERE the product has a promo price THEN the system SHALL render the discount badge and the
   original price struck through alongside the promo price.
3. WHEN a reseller selects a color THEN the system SHALL enable only the sizes that have a matching
   variant for that color, per `enabledSizes`.
4. WHEN a reseller selects a size THEN the system SHALL enable only the colors that have a matching
   variant for that size, per `enabledColors`.
5. The system SHALL derive `selectedVariant` from the current color+size pair and SHALL be `nil`
   when no variant matches.
6. WHILE a variant is selected the system SHALL cap the quantity stepper at that variant's stock
   (`maxQuantity`), never allowing a quantity above stock on hand.
7. The system SHALL render the spec section (category, dimensions, barcode, SKU) and a stock
   indicator for the selected variant.

**Independent Test**: open a product with 2+ colors and 2+ sizes where not every combination exists;
confirm selecting one color disables sizes with no variant, and the quantity stepper never exceeds
the selected variant's stock.

---

### P2: Buy / Add to cart (placeholder today)

**User Story**: As a reseller, I want to buy the selected variant so I can actually place an order.

**Why P2**: real behavior is Phase 3 — today this is intentionally a placeholder, not a bug.

**Acceptance Criteria**:

1. WHEN a reseller taps Buy or Add to cart today THEN the system SHALL show `showComingSoon()` via
   `MessagesServiceProtocol` — this is the current, correct behavior, not a defect.
2. WHEN Phase 3 ships a cart, THEN this AC SHALL be superseded by the cart feature's own spec —
   tracked there, not rewritten here prematurely.

**Independent Test**: tap Buy on any product — see the "Coming soon" toast, nothing else happens.

---

## Edge Cases

- IF `selectedVariant` is `nil` (no matching variant for the chosen color+size) THEN the system
  SHALL disable Buy/Add-to-cart rather than allow a purchase of an invalid combination.
- IF a variant's `status` decodes as `unknown` (AD-005) THEN it SHALL be treated as not purchasable,
  per that spec's degrade rule — this screen must not assume `status` is always one of the known
  cases.
- IF stock for the selected variant is `0` THEN the quantity stepper SHALL be disabled and the stock
  indicator SHALL communicate out-of-stock, not just cap the stepper at `0` silently.

---

## Requirement Traceability

| Requirement ID | Story | Phase | Status |
| --- | --- | --- | --- |
| PDET-01 | P1: carousel + core info | Specify | Shipped |
| PDET-02 | P1: promo price/badge | Specify | Shipped |
| PDET-03 | P1: color→size constraint | Specify | Shipped |
| PDET-04 | P1: size→color constraint | Specify | Shipped |
| PDET-05 | P1: selectedVariant derivation | Specify | Shipped |
| PDET-06 | P1: maxQuantity cap | Specify | Shipped |
| PDET-07 | P1: spec section + stock indicator | Specify | Shipped |
| PDET-08 | P2: Buy/Add-to-cart placeholder | Specify | Shipped (as a placeholder — correct current behavior) |

**ID format:** `PDET-NN`.

**Coverage:** 8 total, 8 shipped as currently scoped; PDET-08 is intentionally a placeholder pending
Phase 3 ⚠️.

---

## Success Criteria

- [x] `ProductDetailsViewModel`'s variant logic never lets a reseller select an invalid
      color/size/quantity combination.
- [ ] `ProductDetailsViewModel`'s variant logic has unit tests (Trello #102 — the single highest-value
      test target per `.claude/CLAUDE.md`; not yet written).
