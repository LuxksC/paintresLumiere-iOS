# API Decoding Resilience Specification

## Problem Statement

`ProductCategory`, `ProductStatus` and `ProductColor` are plain `String, Decodable` enums with a
closed case set mirroring Postgres enums. `JSONDecoder` throws when a raw value doesn't match any
case, and because these are non-optional properties of `Product`/`ProductVariant`, that throw fails
the decode of the *entire* array. One new category or color on the backend takes down the whole
catalog for every product — not just the one that changed. This is a latent bug today (Trello
#207), not yet exercised, but it stops being hypothetical the moment real catalog data (#16) or
admin-created products (#196) introduce a value the client doesn't know about.

## Goals

- [ ] An unrecognized enum value degrades the one field it affects, never the whole decode.
- [ ] The rule is documented and applied to every future API-decoded enum (cart, order, payment),
      not just the three that exist today.

## Out of Scope

| Feature | Reason |
| --- | --- |
| Changing what values `ProductCategory`/`ProductStatus`/`ProductColor` actually contain | This spec is about decode *resilience*, not the enum's business meaning. |
| Retrofitting every non-enum decode failure mode | Scoped strictly to enums with a closed case set decoded from the API — not a general error-handling audit. |

---

## Assumptions & Open Questions

| Assumption / decision | Chosen default | Rationale | Confirmed? |
| --- | --- | --- | --- |
| Mechanism shape | A `UnknownCaseDecodable` protocol (`RawRepresentable & Decodable`, `RawValue == String`) with a required `static var unknown: Self`, decoding via a protocol extension `init(from:)` that falls back to `.unknown` instead of throwing | This is the mechanism `.claude/CLAUDE.md`'s Networking section and Trello #207 both already sketch — adopting it rather than inventing a second approach keeps the codebase and the doc in sync | y |
| Behavior of each `.unknown` case | Degrade, never break: `ProductStatus.unknown` → not purchasable; `ProductCategory.unknown` → hidden from category grids/filters but the product stays listable; `ProductColor.unknown` → not offered in the variant selector, with a neutral swatch/fallback display name | Explicit rule from `.claude/CLAUDE.md` and the Trello card description — not left to per-enum improvisation | y |
| `CaseIterable` exposure | `ProductColor.allCases` (consumed by `PLColorSelector`) must exclude `.unknown` — either a manual `CaseIterable` implementation or a filter at the consumption site | Adding `unknown` naively leaks it into `allCases`, and `PLColorSelector` has no other guard today | y |

**Open questions:** none — all resolved or logged above.

---

## User Stories

### P1: A malformed/unknown value degrades one field, not the array ⭐ MVP

**User Story**: As a reseller, I want the catalog to keep working even if the backend introduces a
product category or color my app version doesn't recognize yet.

**Why P1**: this is the core defect — everything else in this spec is refinement on top of it.

**Acceptance Criteria**:

1. The system SHALL define `UnknownCaseDecodable` in `Commons/` and conform `ProductCategory`,
   `ProductStatus`, and `ProductColor` to it.
2. WHEN a `Product` or `ProductVariant` payload contains a `category`, `status`, or `color` value
   with no matching case THEN the system SHALL decode that field as `.unknown` rather than throwing.
3. WHEN one product in a `GET /products` array response has an unknown enum value THEN the system
   SHALL still successfully decode every other product in that same array.
4. The system SHALL NOT throw a decoding error solely because of an unrecognized enum raw value on
   these three types.

**Independent Test**: decode a fixture payload where one product has an unrecognized `category`,
`status`, and `color` — confirm the whole array decodes, that product's three fields are `.unknown`,
and every other product is unaffected.

---

### P1: Unknown values degrade correctly per field ⭐ MVP

**User Story**: As a reseller, I don't want to be able to buy something whose status my app can't
actually interpret, and I don't want a broken-looking option in a selector.

**Why P1**: decoding safely is only half the fix — the *consequences* of `.unknown` have to be safe
too, or the crash just becomes a silent wrong purchase instead.

**Acceptance Criteria**:

1. IF a variant's `status` decodes as `.unknown` THEN the system SHALL treat it as not purchasable —
   the same as any other non-purchasable status.
2. IF a product's `category` decodes as `.unknown` THEN the system SHALL exclude it from the
   category grid and category filters, WHILE still listing the product in the general catalog.
3. IF a variant's `color` decodes as `.unknown` THEN the system SHALL exclude it from
   `PLColorSelector`'s offered options, using a neutral swatch and fallback display name in any
   place it must still be rendered (e.g., an existing cart line referencing that variant).
4. `ProductColor.allCases`, as consumed by `PLColorSelector`, SHALL NOT include `.unknown`.

**Independent Test**: render `PLColorSelector` for a variant set including an unknown color —
confirm it never appears as a selectable swatch; confirm a product with unknown category is absent
from the category grid but present in the flat catalog list.

---

### P2: Apply the same rule to every future API-decoded enum

**User Story**: As the team building cart/order/payment features next, I want the same safety net
by default, not something I have to remember to re-derive.

**Why P2**: protects Phases 3–4 (cart, order, payment enums) from reintroducing the exact same bug
class — important, but there's nothing to build for it until those enums exist.

**Acceptance Criteria**:

1. WHERE a new enum is introduced to decode an API field with a closed, backend-mirrored case set
   THEN it SHALL conform to `UnknownCaseDecodable` from the start, rather than being added as a
   plain `String, Decodable` enum and retrofitted later.

**Independent Test**: code-review checklist item for every future PR touching Phase 3/4 models —
not independently demoable today.

---

## Edge Cases

- IF a payload's enum field is missing entirely (not just an unrecognized value) THEN this spec does
  not change that behavior — `UnknownCaseDecodable` only changes what happens to a *present but
  unrecognized* raw value, never a fully absent required field.
- IF `.unknown` needs to be displayed somewhere unavoidable (e.g., an order placed before a category
  was renamed) THEN a neutral fallback label SHALL be shown — never the raw, un-humanized string
  from the API.

---

## Requirement Traceability

| Requirement ID | Story | Phase | Status |
| --- | --- | --- | --- |
| ADR-01 | P1: protocol + conformance | Specify | Pending — Trello #207 |
| ADR-02 | P1: single-field degrade on decode | Specify | Pending |
| ADR-03 | P1: array-level resilience | Specify | Pending |
| ADR-04 | P1: no throw on unknown raw value | Specify | Pending |
| ADR-05 | P1: unknown status not purchasable | Specify | Pending |
| ADR-06 | P1: unknown category hidden from grid/filters | Specify | Pending |
| ADR-07 | P1: unknown color excluded from selector | Specify | Pending |
| ADR-08 | P1: `allCases` excludes `.unknown` | Specify | Pending |
| ADR-09 | P2: rule applies to future enums | Specify | Pending (process requirement, not code) |

**ID format:** `ADR-NN`.

**Coverage:** 9 total, 0 shipped — this feature has not started; see AD-005 in `.specs/STATE.md` ⚠️.

---

## Success Criteria

- [ ] No single unrecognized enum value can fail an entire catalog fetch.
- [ ] `ProductDetailsViewModel`'s variant logic (already spec'd in `.specs/features/product-details/spec.md`)
      never treats an unknown status as purchasable or offers an unknown color.
