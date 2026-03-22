---
title: BabyVinci PRD
status: active
canonical: true
source_of_truth: PRD.md
design_reference: DESIGN.md
progress_tracker: PRD.md#progress-tracker
current_phase: "Phase 1 - Shared Essential Logging MVP"
last_updated: 2026-03-23
agent_instruction: "Use this file as the canonical product spec and progress tracker. Continue in phase order unless explicitly directed otherwise. Update the progress tracker after completed work."
---

# PRD.md — BabyVinci - Calm Baby Companion

## Status
Active canonical product spec

## Progress Tracker

- Current phase: Phase 1 - Shared Essential Logging MVP
- Current milestone: Phase 1 in progress
- Current task: P1-04 Shared timeline
- Blockers: None
- Last updated: 2026-03-23

### Phase 1 tracker
- [x] P1-01 Parent sign up / sign in
- [x] P1-02 Create one baby profile
- [x] P1-03 Today dashboard
- [ ] P1-04 Shared timeline
- [ ] P1-05 Quick log: feed
- [ ] P1-06 Quick log: diaper
- [ ] P1-07 Edit and delete recent events
- [ ] P1-08 Invite second parent
- [ ] P1-09 Mobile-first layout
- [ ] P1-10 Phase 1 launch polish / QA

### Phase 2 tracker
- [ ] P2-01 Sleep start / end flow
- [ ] P2-02 Today sleep state
- [ ] P2-03 Guidance notes on Today
- [ ] P2-04 Guidance content seeds

### Phase 3 tracker
- [ ] P3-01 Fixed concern flows
- [ ] P3-02 Initial concern content set
- [ ] P3-03 Doctor summary export
- [ ] P3-04 Concern history / saved results

### Phase 4 tracker
- [ ] P4-01 Appointments (optional)
- [ ] P4-02 Milestones (optional)
- [ ] P4-03 Offline core event queue (optional)
- [ ] P4-04 Pending sync and retry UX (optional)

## Purpose
Build a brain-dead simple shared app for two parents to care for one infant from birth onward.

This app is for real daily use by tired parents, not for demos, not for investor slides, and not for feature theater.

It must help with four jobs only:

1. remember what happened recently
2. show what matters right now
3. make it easy to notice when to get help
4. prepare useful context for doctor visits

Every phase must end in something the parents can already use that day.

---

## Product Summary
A shared, calm baby companion for two parents.

The app should feel like a quiet second brain during the first months of parenting.

It is:
- a shared timeline for the essentials
- a calm age-aware dashboard
- a lightweight safety and guidance layer
- a simple doctor-visit prep tool

It is not:
- a medical diagnosis app
- a giant tracker
- a social network
- a growth analytics dashboard
- a parenting content warehouse

---

## Product Principles

### 1. Calm over clever
The app must reduce stress, not create more of it.

### 2. One-hand use first
Every core action should be possible while holding a baby.

### 3. Shared by both parents
The product is not single-user in spirit. Both parents must see the same baby timeline.

### 4. Log only what changes decisions
If a data point does not help the parent decide what to do next, it should not be first-class.

### 5. No medical theater
The app may guide and escalate. It must not pretend to diagnose.

### 6. Every phase shippable
No long setup phase. No hidden “foundation” milestone that users cannot benefit from.

### 7. Mobile web first, native later if ever
Fast deployment matters more than store packaging.

---

## Target Users

### Primary users
- Mother
- Father / partner

### Context
- sleep-deprived
- often one-handed
- often interrupted
- often anxious about whether something is normal
- may hand off care to each other frequently

### Assumptions
- one household
- one baby in v1
- both parents have separate accounts
- both parents can add and view shared records

---

## Jobs To Be Done

### Functional jobs
- Log the last feed quickly
- Log the last diaper quickly
- See what happened recently
- Know baby’s current age and stage
- See the next helpful guidance for this stage
- Flag concerns and know what to do next
- Prepare a clean summary for a clinic visit

### Emotional jobs
- Reduce second-guessing
- Reduce “I forgot when that happened” stress
- Reduce conflict between parents caused by missing context
- Avoid making parents feel judged or behind

---

## Delivery Model

- `PRD.md` is the canonical product spec and execution tracker.
- Phase 1 is the detailed launch target.
- Phases 2-4 are intentionally lighter until real-world use begins.
- Do not treat the full product scope as a prerequisite for launch.
- Build and verify in phase order unless an explicit decision changes priority.

---

## Scope

### In scope now (Phase 1 launch)
- Phase 1 is the launch target.
- It must be useful before any later-phase work begins.
- shared baby profile
- shared timeline of care events
- quick logging for feed and diaper
- Today screen with baby age, latest feed, latest diaper, and recent events
- invite second parent
- edit and delete recent events
- mobile-first web app

### Likely follow-on scope after launch
- sleep logging
- 1-2 age-based guidance notes on Today
- a small set of conservative concern flows
- printable doctor summary
- optional appointments, milestones, and offline experiments only if real use justifies them

### Out of scope
- AI chatbot
- social/community feed
- photo journaling
- pumping freezer inventory
- breastfeeding analytics obsession
- wake-window coaching
- percentile and growth chart obsession
- multi-baby support
- nanny/grandparent roles
- telemedicine
- e-commerce
- push-notification heavy workflows
- wearable or nursery device integrations
- long-form medical encyclopedia

---

## Hard Constraints

### Product constraints
- single baby only in v1
- exactly two parent accounts supported in the main UX
- no feature that requires daily maintenance to feel complete
- no feature that shames the parent for missing logs
- no charts as the primary dashboard surface
- no empty-state guilt language

### Medical constraints
- the app must not diagnose conditions
- concern flows must be rules-based, conservative, and finite
- free-text symptom interpretation is out of scope
- high-risk concern content must always end with clear escalation guidance
- medical copy should avoid false certainty

### Technical constraints
- Rails 8 only
- Hotwire first: Turbo + Stimulus
- mobile web first; installability only if cheap and non-blocking
- minimal JavaScript
- no React
- no mobile-native dependency required for v1
- SQLite is the default database in development, test, and production
- production SQLite files must live on persistent mounted storage and be included in backups
- no websocket complexity required for v1; standard refresh and revisit patterns are enough
- offline support is deferred until proven necessary

### Delivery constraints
- each phase must be independently deployable
- each phase must contain its own QA checklist
- after each phase, the app must be usable immediately by the two parents
- Phase 1 must be useful before installability, offline support, or advanced content systems are considered

---

## Privacy and Trust

- no public profiles, social graph, or third-party family sharing in v1
- exactly two parent accounts can access one baby workspace
- invitation tokens must be single-use and expire
- exports should contain only the selected baby data and be generated on demand
- collect only the data needed for auth, shared care logging, guidance, and export
- product analytics, if any, should stay minimal and avoid care-event payload details
- if parent access removal is ever needed before a safe self-serve flow exists, handle it as a manual admin operation

---

## Success Criteria

### Phase 1 launch success
Within the first week of use, both parents can answer these questions in under 10 seconds:
- When was the last feed?
- When was the last diaper?
- What happened in the last 12 hours?

### Later product success
- What matters at this age right now?

### Secondary success
- A parent can log a core event in under 5 seconds
- A second parent sees the new event quickly after refresh or revisit without confusion
- The app remains understandable at 3 AM
- The app feels calmer than Notes app + chat messages

### Non-goal metrics
Do not optimize for:
- daily streaks
- total time in app
- number of fields filled
- maximum logs per day

---

## UX Principles

### Core UX rules
- giant tap targets
- minimal typing
- “now” is always the default timestamp
- the timeline is more important than charts
- the dashboard is more important than settings
- the app should be useful even with incomplete logs
- every screen should answer one question only

### Tone
Use calm, short, clear language.

Good:
- “You’re okay. Here’s what matters now.”
- “Watch this closely.”
- “Call your pediatrician today.”
- “Seek urgent care now.”

Bad:
- “Optimize infant outcomes.”
- “Your baby is behind.”
- “Risk score: 61%.”
- “You failed to log today.”

### Visual system
- See `DESIGN.md` for canonical visual direction, component rules, and design tokens.

### Information architecture
Top-level navigation should stay tiny:
- Today
- Timeline
- More

Persistent mobile actions should handle:
- Feed
- Diaper

“More” can contain:
- Baby profile
- Invite parent
- Settings

Later-phase features can live under `More` until they prove they deserve top-level navigation.

---

## Core Data Model

This model should stay intentionally small until later phases earn more tables.

### `User`
- id
- name
- email
- password_digest / auth fields
- invited_at
- accepted_at

### `Baby`
- id
- first_name
- birth_at
- created_by_user_id

### `BabyMembership`
- id
- baby_id
- user_id
- role (`parent`)

### `CareEvent`
Single table for core logging.

Fields:
- id
- baby_id
- user_id
- kind (`feed`, `diaper` in Phase 1; add `sleep` only when Phase 2 starts)
- started_at
- ended_at nullable
- payload json
- created_at
- updated_at

Payload examples:
- feed: `{ mode: breast|bottle_breastmilk|formula, amount_ml?, side?, duration_min? }`
- diaper: `{ pee: true|false, poop: true|false, color? }`

### Model notes
- Keep `payload` portable across SQLite-backed environments; favor Rails `json` attributes and small structured values.
- Do not add future-phase tables until the active phase clearly needs them.
- Guidance can start as seeded content in code or YAML.
- Concern flows can start as fixed POROs or plain Ruby structures.
- Do not add soft delete in the initial build unless a real product need appears.

---

## Delivery Phases

### Phase 1 — Shared Essential Logging MVP

#### Goal
Ship the minimum version that both parents can use immediately for daily baby care.

#### Why this phase exists
This phase solves the core memory problem first.
Without this phase, the rest is decoration.

#### Features
- parent sign up / sign in
- create one baby profile
- Today screen
- shared timeline
- quick log: feed
- quick log: diaper
- edit and delete recent events
- invite second parent
- mobile-first layout

#### Explicit exclusions in Phase 1
- sleep logging
- guidance cards
- concern checker
- milestones
- appointments
- export
- installability if it delays shipping
- offline queued writes beyond very basic browser form resilience

#### User stories
- As a parent, I can log a feed in a few taps.
- As a parent, I can log a diaper in a few taps.
- As a parent, I can open the app and know the last feed and diaper instantly.
- As a parent, I can correct a mistaken entry without confusion.
- As a parent, I can invite my partner once the app is already useful.

#### Functional specifications

### Auth and family setup
- User can create an account.
- User can create one baby.
- User can start logging before inviting the second parent.
- User can invite one other parent by email.
- Invited parent joins the same baby workspace.
- Both parents have equal permissions in v1.

### Feed logging
Required:
- timestamp default `now`
- mode: breast / bottle breastmilk / formula

Optional:
- amount_ml
- side (`left`, `right`, `both`)
- duration_min

Rules:
- only one required field beyond timestamp: mode
- saving should take 1 screen and 1 submit
- last used mode may be preselected if safe

### Diaper logging
Required:
- timestamp default `now`
- type: wet / poop / both

Optional:
- poop color note

Rules:
- one tap to choose type
- save should feel faster than opening Notes

### Dashboard
Show:
- baby name
- age label
- time since last feed
- time since last diaper
- recent 8 timeline entries
- sticky primary action buttons: Feed, Diaper

### Timeline
- reverse chronological
- grouped by day
- simple event rows
- event author visible in small text
- tap to edit / delete

#### Screens
- Sign in
- Create baby
- Today
- Timeline
- Feed form
- Diaper form
- Edit event
- Invite parent
- More / Settings

#### Acceptance criteria
- A single parent can create an account, create a baby, and log the first event without inviting anyone first.
- Two separate accounts can see the same baby data.
- A feed can be logged in under 5 seconds on mobile.
- A diaper can be logged in under 5 seconds on mobile.
- A second parent can understand the last 12 hours in under 10 seconds.
- The timeline is understandable with no onboarding needed.
- The app is useful in a mobile browser without installation.

#### QA / verification

### Manual QA checklist
- Create parent A account.
- Create baby.
- Log a feed before inviting parent B.
- Log a diaper before inviting parent B.
- Invite parent B.
- Accept invite from a different browser/device.
- Refresh or revisit and confirm parent B sees the existing feed.
- Log diaper from parent B.
- Refresh or revisit and confirm parent A sees the new diaper.
- Edit an event.
- Delete an event.
- Verify age label shows correctly.
- Verify mobile layout on common phone widths.

### Edge cases
- Invite is sent later, not during first session.
- Parent B opens invite twice.
- Network interruption on save.
- Two events logged close together.
- Optional fields left blank.

#### Release check
If this phase is done, the app is already useful.
The parents can use it as a shared memory system immediately.

---

### Phase 2 — Sleep + Age-Based Guidance

#### Goal
Make the app feel like a calm companion, not only a logger.

#### Why this phase exists
Logging alone is helpful, but the product becomes much better once it tells parents what matters at the current age.

#### What ships
- sleep start / sleep end
- Today shows active sleep state or latest sleep
- Today shows up to 2 short age-based guidance notes

#### Keep it simple
- no guidance CMS required at first
- guidance can be seeded by age buckets in code or YAML
- one active sleep max per baby
- no wake-window coaching or sleep analytics

#### Acceptance criteria
- Parent can start or end sleep from Today in one tap.
- Only one active sleep can exist.
- Today shows age-appropriate guidance without feeling cluttered.
- Guidance is still useful even if logging is incomplete.

#### QA / verification
- Start sleep and confirm the active state persists after refresh.
- End sleep and confirm the elapsed duration looks correct.
- Backdate baby age and confirm different guidance appears.
- Verify only 2 guidance notes max are shown.

#### Release check
If this phase is done, the app becomes both a tracker and a calm daily companion.
It is still shippable and immediately useful.

---

### Phase 3 — Concern Checker + Doctor Summary Export

#### Goal
Add the highest-leverage support feature without pretending to be a doctor.

#### Why this phase exists
This phase addresses the real parent fear loop: “Is this normal or do we need help?”

#### What ships
- concern entry point from Today or `More`
- 3-5 conservative concern flows with fixed copy
- dispositions: watch closely, call pediatrician today, seek urgent care now
- printable web summary for recent history

#### Keep it simple
- no freeform AI triage
- no open-ended symptom parser
- no generic workflow builder required at first
- printable HTML first; add PDF only if the web version proves insufficient

#### Suggested first concern set
- fever / feels too hot
- too sleepy to feed / hard to wake
- fewer wet diapers / dehydration concern
- trouble breathing / breathing seems wrong
- repeated vomiting / not keeping feeds down

#### Acceptance criteria
- Parent can start a concern flow in under 2 taps.
- Concern flows never accept freeform symptom text as primary input.
- Every concern ends with a clear next step.
- Export is understandable by a parent and useful in a clinic visit.

#### QA / verification
- Run each concern flow from start to finish.
- Verify every answer path ends in a valid disposition.
- Verify urgent results are visually distinct but still calm.
- Generate each export window and validate event counts.

#### Safety QA
- Review all concern copy for false certainty.
- Review urgent outcomes for explicit action language.
- Confirm no flow claims diagnosis.
- Confirm every result points back to local professional care when appropriate.

#### Release check
If this phase is done, the app becomes meaningfully more valuable in real life.
It is still narrow enough to remain trustworthy.

---

### Phase 4 — Appointments + Milestones + Offline Core

#### Goal
Round out the product only if real use proves these additions matter.

#### Why this phase exists
These features help with continuity of care, but they are weaker than the earlier phases, so they come later.

#### What may ship
- simple appointments list with notes
- milestone check-ins at 2, 4, and 6 months
- basic offline support for creating core care events

#### Keep it simple
- no deep vaccine schedule intelligence
- no milestone scoring or comparison dashboard
- no advanced offline conflict-resolution UI
- do not build offline unless real users actually hit this problem

#### Acceptance criteria
- Parent can create and complete appointments if appointments ship.
- Milestones do not use "behind" language if milestones ship.
- Core logs can be created offline and later retried if offline support ships.
- Failed sync states are visible and recoverable if offline support ships.

#### QA / verification
- Add and complete an appointment if appointments ship.
- Complete milestone check-ins for each age bucket if milestones ship.
- Go offline, create core events, restore network, and confirm sync if offline support ships.
- Confirm no duplicate events are created during retry.

#### Release check
If this phase is done, the app is a strong private family tool and can be used with confidence day to day.

---

## Recommended Build Order Inside Rails

### Suggested order
1. auth + baby creation
2. care event model + timeline
3. Today dashboard queries
4. feed and diaper forms
5. invite second parent
6. sleep state logic if Phase 2 starts
7. seeded guidance notes if Phase 2 starts
8. fixed concern flows if Phase 3 starts
9. printable export view if Phase 3 starts
10. appointments, milestones, and offline only after real use proves they matter

### Keep implementation boring
Prefer:
- conventional controllers
- small POROs for concern logic when Phase 3 starts
- server-rendered Turbo flows
- a tiny Stimulus layer for quick interactions
- Prefer Sandi Metz OOD
- Basecamp/37Signals style coding
- Vanilla Rails

Avoid:
- frontend state machines unless needed
- over-abstracted service object forests
- content engines before seeded content feels insufficient
- giant event bus architecture
- premature domain micro-objects everywhere

---

## Suggested Routes / Surface Area

Keep route surface tiny.

- `/today`
- `/timeline`
- `/feeds/new`
- `/diapers/new`
- `/settings`

Add later-phase routes only when those features actually ship.

---

## Content Rules

### Guidance cards
- short
- practical
- age-scoped
- supportive
- not repetitive

### Concern content
- finite
- conservative
- reviewed carefully before launch
- no speculation
- no diagnosis language

### Milestone content
- observational
- discussion-oriented
- not evaluative

### Concern review gate
- Every concern flow must be reviewed by the designated product owner against trusted pediatric references before release.
- Every answer path must be manually tested before shipping.
- Any copy that could imply diagnosis, certainty, or treatment beyond escalation guidance must be removed.
- Urgent outcomes must end with a plain action statement.

---

## Visual Reference

- Canonical visual design reference: `DESIGN.md`
- `PRD.md` owns product scope, behavior, and acceptance criteria.

---

## Risks and Tradeoffs

### Risk 1: tracker bloat
Response:
- protect quick log simplicity
- do not promote optional fields too heavily

### Risk 2: medical overreach
Response:
- rules-based finite concerns only
- conservative language
- no AI diagnosis

### Risk 3: content sprawl
Response:
- small guidance library
- strict templates
- no giant article system

### Risk 4: offline complexity
Response:
- support only core event creation offline
- defer complex conflict handling

### Risk 5: parent disagreement on what matters
Response:
- shared timeline first
- equal permissions
- clear event attribution

---

## Launch Recommendation

### Fastest path to real use
Ship in this order:
1. Phase 1
2. Phase 2
3. Phase 3
4. Phase 4

Do not wait for all phases.
Use it yourselves starting at Phase 1.

### Why
- Phase 1 already solves a real pain
- Phase 2 makes it feel meaningfully better
- Phase 3 adds trust and utility
- Phase 4 rounds it out without blocking launch

---

## Final Product Boundary

If a feature does not make one of these better, reject it:
- shared memory
- current-age guidance
- clear next step for concern
- better doctor conversation

That is the product.
