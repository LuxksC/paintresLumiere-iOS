---
description: Catch up on the iOS project — reads .specs/STATE.md + feature specs, checks recent PRs, cross-checks Trello, reports what shipped, what's next, and what's blocked.
---

## Purpose

Lucas works on this project only on weekends and regularly loses track of where the iOS app was
left. This command re-orients him in one pass: what shipped since he last looked, what the next
cards are (in the project's own phase/priority order), and which of those next steps he cannot
actually start yet because they wait on him or on the backend.

Run this at the start of a session, before picking up any work.

This command replaced `/handoff-check` on 2026-09-20, when the static `HANDOFF.md` snapshot was
retired in favor of this repo's own `.specs/` tree (via the `tlc-spec-driven` skill). If `.specs/`
is ever missing, say so explicitly rather than silently proceeding as if nothing changed.

## Steps

### 1. Read this repo's spec-driven memory

- Read `.specs/STATE.md`. It has two independent sections:
  - `## Decisions` — an append-only log (`AD-NNN`) of project-level iOS conventions and their
    trade-offs. Treat these as currently active unless an entry says `superseded by AD-NNN`.
  - `## Handoff` — a ~500-token pause/resume snapshot: last feature touched, what's done, the next
    step, blockers, uncommitted files, branch. Treat it as a **hypothesis**, not ground truth — it
    gets reconciled against git in step 2.
- Skim every `.specs/features/*/spec.md`'s **Requirement Traceability** table (just that table, not
  the full spec) to know, per feature, what's `Shipped` vs `Pending` and why. This is the direct
  replacement for what `HANDOFF.md` §4/§5 used to describe by hand — it will drift out of date if a
  spec's traceability table isn't kept current, so flag it if a spec's status looks stale against
  what git/Trello actually show.
- Read `../STATE.md` (the workspace root, one level up). This stays the **cross-repo** live
  document — backend/Android status, the current Trello cycle, owner-level decisions. It explicitly
  wins over anything repo-local when the two disagree, per its own header. Do not confuse it with
  this repo's `.specs/STATE.md` — they answer different questions (workspace-wide vs. this repo's
  spec/decision log) and both matter.

### 2. Check git and recent Pull Requests

- `git log --oneline -15` and `git status` in this repo. Reconcile against `.specs/STATE.md`'s
  `## Handoff` section — evidence from git wins over a stale snapshot (same rule the skill's own
  resume procedure uses). Note explicitly when recent commits are already ahead of what `STATE.md`
  or a feature spec's traceability table claims.
- Check recent Pull Requests with `gh pr list --state merged --limit 10` and
  `gh pr list --state open` (requires `gh` to be authenticated against this repo's remote). PRs are
  where "what actually landed and why" lives per `.claude/CLAUDE.md`'s PR-description conventions
  (decisions that changed course, what a reviewer checked) — a merged PR can reveal scope or
  direction changes that never made it back into `.specs/STATE.md` or a spec's traceability table.
  For anything non-obvious, `gh pr view <number>` to read the description, not just the title.
  If `gh` is not available or not authenticated, say so explicitly and fall back to git log alone —
  do not silently skip this check.

### 3. Pull the live board state from Trello

Use the Trello MCP tools (the board is already scoped via `.mcp.json`'s `TRELLO_BOARD_ID`):

- `get_active_board_info` (or `get_lists` if that fails) to confirm the current lists.
- `get_cards_by_list_id` for **DOING**, **TODO**, and the top of **Backlog** (the board is kept
  ordered top-down by phase then priority — read it in board order, don't re-sort it).
- For any card referenced in `.specs/STATE.md` or a feature spec that looks like it might have
  moved, pull it with `get_card` to check its current list/status rather than trusting the snapshot.
- Every card description should carry a `**Fase N** · **Prioridade PN**` header — use that (not
  guesswork) to group findings by phase and priority.

### 4. Filter to what actually matters for the iOS client

This is the iOS repo, so weight the report toward cards that touch `paintresLumiere-ios` directly —
use `.specs/features/*/spec.md` as the map of what's already modeled (authentication, product
catalog, product details, profile, Google/Apple Sign-In, API decoding resilience, and whatever else
exists by the time this runs) plus whatever Trello cards don't have a spec yet. Still surface
backend-only or cross-cutting cards **when the iOS work is blocked on them** — that is the whole
point of §5 below — but don't pad the report with backend-internal work that has no iOS-side
dependency.

### 5. Report, in this shape

**a. Where we left off** — the last things actually developed (from git log + recent merged PRs +
`.specs/STATE.md`'s `## Handoff` section + each feature spec's traceability table). Be concrete:
card numbers, PR numbers, what shipped, what state the build/tests were in.

**b. What's next** — the next cards in board order, respecting phase and priority (pull straight
from DOING → TODO → top of Backlog, grouped by phase). Cross-reference against any feature spec
whose traceability table already has `Pending` requirements mapped to that card — say so, since it
means the spec is ready to go straight to Design/Tasks/Execute instead of needing a fresh Specify
pass.

**c. What's blocking forward progress**, split into two groups, and be explicit about which is
which:
   - **Waiting on you** — anything that needs an action only Lucas can take: provisioning an
     account, an API key, a decision, manual Trello UI work, or an open question neither `.specs/`
     nor `../STATE.md` has resolved yet.
   - **Waiting on the backend** — iOS cards that cannot proceed until `paintresLumiere-api` ships
     something first, or where the payload shape must be agreed cross-repo before either side
     implements. Several feature specs already name their blocking backend card in their
     Assumptions or Out-of-Scope tables — use those, then verify on Trello that the card is still
     open rather than assuming.

   For each blocker, name the specific card(s) involved and what unblocks it.

Keep the report skimmable — headers and short bullets, not prose paragraphs. Card and PR numbers as
plain `#123` are fine here (this is a terminal report, not a PR description).

### 6. Close every run with this question

After presenting the four sections above, always end by asking Lucas:

> Is there anything you want to add or change in the plan, or should I go ahead and start on the
> next steps?

Do not start implementing anything until he answers. If he says to proceed, confirm which specific
card(s)/feature(s) from "What's next" he means before writing code — the report may have surfaced
several. If the chosen work already has a `.specs/features/<name>/spec.md`, resume the
`tlc-spec-driven` workflow from there (Design/Tasks/Execute as auto-sized) instead of starting a
fresh Specify pass.
