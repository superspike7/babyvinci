---
title: BabyVinci PRD
status: active
canonical: true
source_of_truth: PRD.md
progress_tracker: PRD.md#progress-tracker
current_phase: "Phase 1 - Shared Essential Logging MVP"
last_updated: 2026-03-22
agent_instruction: "Use this file as the canonical product spec and progress tracker. Continue in phase order unless explicitly directed otherwise. Update the progress tracker after completed work."
---

# PRD.md — BabyVinci - Calm Baby Companion

## Status
Active canonical product spec

## Progress Tracker

- Current phase: Phase 1 - Shared Essential Logging MVP
- Current milestone: Not started
- Current task: P1-01 Parent sign up / sign in
- Blockers: None
- Last updated: 2026-03-22

### Phase 1 tracker
- [ ] P1-01 Parent sign up / sign in
- [ ] P1-02 Invite second parent
- [ ] P1-03 Create one baby profile
- [ ] P1-04 Shared timeline
- [ ] P1-05 Quick log: feed
- [ ] P1-06 Quick log: diaper
- [ ] P1-07 Today dashboard
- [ ] P1-08 Edit and delete recent events
- [ ] P1-09 Mobile-first layout
- [ ] P1-10 Installable PWA shell

### Phase 2 tracker
- [ ] P2-01 Sleep start / end flow
- [ ] P2-02 Today sleep state
- [ ] P2-03 Guidance card engine
- [ ] P2-04 Guidance content seeds

### Phase 3 tracker
- [ ] P3-01 Concern flow runner
- [ ] P3-02 Initial concern content set
- [ ] P3-03 Concern session history
- [ ] P3-04 Doctor summary export

### Phase 4 tracker
- [ ] P4-01 Appointments
- [ ] P4-02 Milestones
- [ ] P4-03 Offline core event queue
- [ ] P4-04 Pending sync and retry UX

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

### 7. PWA first, native later if ever
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
- Phase 1 is the first launch candidate.
- Phases 2-4 extend the product after real-world use begins.
- Do not treat the full product scope as a prerequisite for launch.
- Build and verify in phase order unless an explicit decision changes priority.

---

## Scope

### In scope across Phases 1-4
- This is the full intended product envelope for the current PRD.
- Each phase is independently shippable.
- Phase 1 is enough to launch and begin real use.

- shared baby profile
- shared timeline of care events
- quick logging for feed, diaper, sleep
- dashboard with baby age and latest events
- age-based guidance cards
- conservative concern checker
- doctor summary export
- lightweight milestones
- appointments and vaccine notes
- installable PWA with basic offline support for core logging

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
- PWA first
- minimal JavaScript
- no React
- no mobile-native dependency required for v1
- Postgres is the default deployed database
- SQLite is acceptable for local development only
- no websocket complexity required for v1; standard Turbo refresh patterns are enough
- offline support should focus on core event creation only

### Delivery constraints
- each phase must be independently deployable
- each phase must contain its own QA checklist
- after each phase, the app must be usable immediately by the two parents

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

### Primary success
Within the first week of use, both parents can answer these questions in under 10 seconds:
- When was the last feed?
- When was the last diaper?
- What happened in the last 12 hours?
- What matters at this age right now?

### Secondary success
- A parent can log a core event in under 5 seconds
- A second parent sees the new event quickly without confusion
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

### Visual direction
Avoid the usual AI-slop baby app look:
- no random pastel gradients everywhere
- no over-illustrated nursery theme
- no floating glassmorphism cards
- no Dribbble-style decoration that slows use
- no cartoon overload

Preferred direction:
- clean typography
- quiet spacing
- mostly neutral backgrounds
- one accent color only
- high contrast
- information-led layout
- subtle warmth, not cuteness overload

### Design system guidance
- 8px spacing scale
- 16px or larger primary body text
- 44px minimum tap targets
- system font stack or one neutral sans
- cards only when they create separation
- sticky bottom quick actions on mobile
- soft radius, not overly round
- use icons only when they make actions faster
- dark mode supported early

### Information architecture
Top-level navigation should stay tiny:
- Today
- Timeline
- Quick Log
- Guidance
- More

“More” can contain:
- Baby profile
- Appointments
- Milestones
- Export
- Settings

---

## Core Data Model

This model should stay intentionally small.

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
- birth_weight_grams (optional)
- sex / notes optional
- created_by_user_id

### `BabyMembership`
- id
- baby_id
- user_id
- role (`parent`)

### `CareEvent`
Single table for almost all logging.

Fields:
- id
- baby_id
- user_id
- kind (`feed`, `diaper`, `sleep`)
- started_at
- ended_at nullable
- payload json
- created_at
- updated_at

Payload examples:
- feed: `{ mode: breast|bottle_breastmilk|formula, amount_ml?, side?, duration_min? }`
- diaper: `{ pee: true|false, poop: true|false, color? }`
- sleep: `{ quality?: short_note }`

### `GuidanceCard`
- id
- starts_day
- ends_day
- category
- title
- body
- priority
- active

### `ConcernFlow`
- id
- slug
- title
- active

### `ConcernStep`
- id
- concern_flow_id
- position
- prompt
- response_type
- options json
- outcome_map json

### `ConcernSession`
- id
- baby_id
- user_id
- concern_flow_id
- answers json
- disposition (`watch`, `call_today`, `urgent_now`)
- created_at

### `Appointment`
- id
- baby_id
- kind (`checkup`, `vaccine`, `other`)
- scheduled_at
- status (`scheduled`, `done`, `cancelled`)
- notes

### `MilestoneCheck`
- id
- baby_id
- age_months (`2`, `4`, `6`)
- item_key
- status (`observed`, `not_yet`, `unsure`)
- recorded_by_user_id
- recorded_at

### Model notes
- Use a native JSON column type supported by the deployed database.
- Do not add soft delete in the initial build unless a real product need appears.
- Concern sessions stay separate from `CareEvent`; if needed, render them into the timeline as derived items.

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
- invite second parent
- create one baby profile
- shared timeline
- quick log: feed
- quick log: diaper
- dashboard showing:
  - baby age in days/weeks/months
  - latest feed
  - latest diaper
  - recent timeline entries
- edit and delete recent events
- mobile-first layout
- installable PWA shell

#### Explicit exclusions in Phase 1
- sleep logging
- concern checker
- milestones
- appointments
- export
- offline queued writes beyond very basic browser form resilience

#### User stories
- As a parent, I can invite my partner so we share the same baby timeline.
- As a parent, I can log a feed in a few taps.
- As a parent, I can log a diaper in a few taps.
- As a parent, I can open the app and know the last feed and diaper instantly.
- As a parent, I can correct a mistaken entry without confusion.

#### Functional specifications

### Auth and family setup
- User can create an account.
- User can create one baby.
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
- primary CTA buttons: Feed, Diaper

### Timeline
- reverse chronological
- grouped by day
- simple event rows
- event author visible in small text
- tap to edit / delete

#### Screens
- Sign in
- Create baby
- Invite parent
- Today
- Timeline
- Quick log feed
- Quick log diaper
- Edit event

#### Acceptance criteria
- Two separate accounts can see the same baby data.
- A feed can be logged in under 5 seconds on mobile.
- A diaper can be logged in under 5 seconds on mobile.
- The dashboard updates correctly after a new event.
- The timeline is understandable with no onboarding needed.
- The app is installable as a PWA on mobile.

#### QA / verification

### Manual QA checklist
- Create parent A account.
- Create baby.
- Invite parent B.
- Accept invite from a different browser/device.
- Log feed from parent A.
- Confirm feed appears for parent B.
- Log diaper from parent B.
- Confirm diaper appears for parent A.
- Edit an event.
- Delete an event.
- Verify age label shows correctly.
- Verify mobile layout on common phone widths.

### Edge cases
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

#### Features
- quick log: sleep start / sleep end
- dashboard now shows latest sleep
- age-based guidance cards on Today screen
- guidance categories:
  - feeding
  - sleep safety
  - development/play
  - care basics
- admin/seeds for guidance card content

#### Explicit exclusions in Phase 2
- concern checker
- export
- appointments
- milestones
- advanced sleep analytics
- wake window recommendations

#### User stories
- As a parent, I can log sleep start and wake with minimal taps.
- As a parent, I can see one or two useful guidance cards for my baby’s current age.
- As a parent, I can learn something useful today without reading a long article.

#### Functional specifications

### Sleep logging
Actions:
- Start sleep now
- End current sleep now
- Manual sleep entry for missed logs

Rules:
- there can be at most one active sleep event per baby
- if a sleep is active, Today screen should show `Sleeping since ...`
- ending sleep should be one tap from Today

### Guidance card engine
- Each card has a day-range window.
- Today screen shows up to 2 cards max.
- One card should be practical guidance.
- One card may be safety or development guidance.
- No endless feed of cards.

### Content constraints
- Cards must be short.
- Cards must be scannable in under 15 seconds.
- No article page required in v1 unless a card has a small `Learn more` detail page.
- No search required.

#### Screens
- Sleep quick action state on Today
- Manual sleep entry
- Guidance card detail (optional lightweight screen)

#### Acceptance criteria
- Parent can start or end sleep from Today in one tap.
- Only one active sleep can exist.
- Today screen shows age-appropriate cards.
- Guidance remains useful even if parent has not logged much that day.
- The screen still feels calm and uncluttered.

#### QA / verification

### Manual QA checklist
- Start sleep.
- Refresh Today.
- Confirm active sleep state persists.
- End sleep.
- Confirm elapsed duration is correct.
- Backdate baby age and verify different guidance cards appear.
- Verify only 2 cards max are shown.
- Verify cards do not overflow awkwardly on mobile.

### Edge cases
- sleep started accidentally twice
- sleep ended with no active sleep
- baby age crosses from one content window to another

#### Release check
If this phase is done, the app becomes both a tracker and a calm daily companion.
It is still shippable and immediately useful.

---

### Phase 3 — Concern Checker + Doctor Summary Export

#### Goal
Add the highest-leverage support feature without pretending to be a doctor.

#### Why this phase exists
This phase addresses the real parent fear loop: “Is this normal or do we need help?”

#### Features
- concern entry point from Today
- small set of conservative, rules-based concern flows
- dispositions:
  - watch closely
  - call pediatrician today
  - seek urgent care now
- saved concern sessions in timeline or More section
- doctor summary export for recent history

## Concern categories for v1 only
Keep the scope very small:
- fever / feels too hot
- too sleepy to feed / hard to wake
- fewer wet diapers / dehydration concern
- trouble breathing / breathing seems wrong
- repeated vomiting / not keeping feeds down
- yellow skin or eyes getting worse

#### Explicit exclusions in Phase 3
- freeform AI triage
- open-ended symptom parser
- diagnosis suggestions
- broad condition library
- medication dosing guidance

#### User stories
- As a worried parent, I can choose a concern and get a clear next step.
- As a parent, I can see a conservative recommendation without reading a long medical article.
- As a parent, I can export a clean summary before seeing the doctor.

#### Functional specifications

### Concern flows
- Concern flows are finite, not open text.
- Each flow is a small decision tree.
- End states are only: watch, call today, urgent now.
- Every flow includes a final disclaimer that the app does not replace medical care.
- The app must always favor clarity over nuance.

### Concern UX rules
- One question per screen.
- Large answer buttons.
- No percentages.
- No scary color overload.
- Urgent states may use stronger color and icon treatment, but still remain readable and calm.

### Doctor summary export
Export content:
- baby basic info
- recent feeds summary
- recent diaper summary
- recent sleep summary
- logged concerns
- notes entered during concern sessions

Formats:
- printable web page first
- simple PDF later only if needed

Date windows:
- last 24 hours
- last 3 days
- last 7 days
- custom if cheap to add

#### Screens
- Concern entry
- Concern flow question screen
- Concern result screen
- Export preview

#### Acceptance criteria
- Parent can start a concern flow in under 2 taps.
- Concern flows never accept freeform symptom text as the primary input.
- Every concern ends with a clear next step.
- Export is understandable by a parent and useful in a clinic visit.

#### QA / verification

### Manual QA checklist
- Run each concern flow from start to finish.
- Verify every answer path ends in a valid disposition.
- Verify no dead-end screens.
- Verify urgent result is visually distinct.
- Generate each export window and validate event counts.
- Confirm concern sessions are stored correctly.

### Safety QA
- Review all concern copy for false certainty.
- Review all urgent outcomes for explicit action language.
- Confirm no flow claims diagnosis.
- Confirm every result suggests contacting local professional care when appropriate.

#### Release check
If this phase is done, the app becomes meaningfully more valuable in real life.
It is still narrow enough to remain trustworthy.

---

### Phase 4 — Appointments + Milestones + Offline Core

#### Goal
Round out the product without bloating it.

#### Why this phase exists
These features help with continuity of care, but they are weaker than the earlier phases, so they come later.

#### Features
- appointment list
- vaccine / checkup notes
- milestone check-ins at 2, 4, and 6 months
- basic offline support for creating core care events
- sync queued events when connection returns

#### Explicit exclusions in Phase 4
- deep vaccine schedule intelligence
- milestone scoring
- developmental comparison dashboard
- advanced offline conflict resolution UI

#### User stories
- As a parent, I can note upcoming visits.
- As a parent, I can record whether we observed a few milestone items.
- As a parent, I can still log essentials when connectivity is weak.

#### Functional specifications

### Appointments
- simple list view
- create/edit appointment
- mark done
- optional notes

### Milestones
- checkpoint ages: 2 months, 4 months, 6 months
- each item can be marked:
  - observed
  - not yet
  - unsure
- language must encourage discussion, not judgment
- milestone results should not appear as a score

### Offline core
Support offline creation only for:
- feed
- diaper
- sleep start/end

Rules:
- queued entries show pending state
- on reconnect, queued entries sync automatically or on refresh
- if sync fails, user gets plain retry option

#### Screens
- Appointments list/detail
- Milestones check-in
- Pending sync indicator

#### Acceptance criteria
- Parent can create and complete appointments.
- Milestones do not use “behind” language.
- Feed/diaper/sleep logs can be created offline and later synced.
- Failed sync states are visible and recoverable.

#### QA / verification

### Manual QA checklist
- Add appointment.
- Mark appointment complete.
- Complete milestone check at each age bucket.
- Go offline.
- Create feed, diaper, sleep entries.
- Restore network.
- Confirm queued entries sync correctly.
- Confirm no duplicate events are created.

### Edge cases
- two queued entries with same time
- app closed before sync
- user edits an event before queued sync resolves

#### Release check
If this phase is done, the app is a strong private family tool and can be used with confidence day to day.

---

## Recommended Build Order Inside Rails

### Suggested order
1. auth + baby membership
2. care event model + timeline
3. dashboard queries
4. feed and diaper forms
5. sleep state logic
6. guidance seed content
7. concern engine
8. export view
9. appointments
10. milestones
11. service worker / offline queue

### Keep implementation boring
Prefer:
- conventional controllers
- small POROs for concern logic
- server-rendered Turbo flows
- a tiny Stimulus layer for quick interactions
- Prefer Sandi Metz OOD
- Basecamp/37Signals style coding 
- Vanilla Rails

Avoid:
- frontend state machines unless needed
- over-abstracted service object forests
- giant event bus architecture
- premature domain micro-objects everywhere

---

## Suggested Routes / Surface Area

Keep route surface tiny.

- `/today`
- `/timeline`
- `/feeds/new`
- `/diapers/new`
- `/sleep`
- `/guidance`
- `/concerns`
- `/appointments`
- `/milestones`
- `/export`
- `/settings`

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

## Design Guide

### Product feel
This should look like a serious, calm family tool.
Not a toy.
Not a hospital portal.
Not a startup landing page.

### Layout guidance
- mobile-first single column
- sticky bottom action bar on phone
- top summary block on Today
- event list below summary
- use section labels sparingly
- preserve whitespace generously

### Component guidance

### Summary blocks
Use for:
- time since last feed
- time since last diaper
- current sleep state

Should be:
- bold value
- quiet label
- no needless icon decoration

### Event rows
Each row should show:
- event type
- compact details
- time
- author

Must be readable in under 2 seconds.

### Quick actions
Should always remain visible or near-visible on mobile.
Primary actions only.
Do not place low-priority actions beside them.

### Empty states
Calm and matter-of-fact.
Example:
- “No feeds logged yet today.”
- “Start with the next feed.”

Avoid:
- “Looks empty here 😢”
- “Let’s get productive!”

### Motion
- minimal
- mostly instant
- subtle Turbo transitions okay
- no celebratory animation

### Color
- one calm accent
- neutral canvas
- urgent state red reserved for urgent concern results only
- yellow/orange can be used sparingly for caution states

### Typography
- prioritize legibility over personality
- strong numeric rendering for time and age
- clear hierarchy:
  - page title
  - status numbers
  - event labels
  - help text

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
