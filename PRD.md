---
title: BabyVinci PRD
status: active
canonical: true
source_of_truth: PRD.md
design_reference: DESIGN.md
progress_tracker: PRD.md#progress-tracker
current_phase: "Phase 5 - Hotwire Native + Custom Notifications"
last_updated: 2026-03-28
agent_instruction: "Use this file as the canonical product spec and progress tracker. Continue in phase order unless explicitly directed otherwise. Update the progress tracker after completed work."
---

# PRD.md — BabyVinci - Calm Baby Companion

## Status
Active canonical product spec

## Progress Tracker

- Current phase: Phase 5 - Hotwire Native + Custom Notifications
- Current milestone: Phase 5 planned
- Current task: P5-01 Android Hotwire Native shell [NEXT]
- Blockers: None
- Last updated: 2026-03-28

### Latest verification
- 2026-03-23: `bin/rails test` passed for all written Phase 1 coverage.
- 2026-03-23: `agent-browser` verified the full shared-family Phase 1 flow on the local server at `http://127.0.0.1:3000`.
- Browser evidence covered: parent A sign up, baby creation, empty `Today`, pre-invite feed + diaper logging, invite creation, invited member acceptance in a separate session, shared timeline refresh, member logging, parent A refresh, event edit, event delete, age label, and used-invite dead-end state.
- 2026-03-24: `bin/rails test test/integration/baby_invites_test.rb test/integration/mobile_layout_test.rb` passed for the 3-member sharing change.
- 2026-03-24: `agent-browser` verified 3 separate accounts sharing one baby on `http://127.0.0.1:3000`, including second invite creation, third-member acceptance, third-member logging, original-member refresh, and the full shared-access state at 3 people.
- 2026-03-24: `bin/rails test` passed after adding shared next-feed reminder state coverage, including `test/integration/next_feed_reminders_test.rb`.
- 2026-03-24: `agent-browser` verified P2-01 on `http://127.0.0.1:3000` with two shared accounts: member A set the reminder, member B saw it after refresh, member B replaced it, member A saw the updated time after refresh, and member A cleared it with both sessions returning to the empty state.
- 2026-03-24: `bin/rails test` passed after shipping P2-02 reminder card states, server-timed quick presets, and exact-time entry coverage.
- 2026-03-24: `agent-browser` verified P2-02 on `http://127.0.0.1:3000`: empty reminder state, active card layout against the provided reference, edit disclosure exposing quick presets and exact time, and the updated scheduled state.
- 2026-03-24: `bin/rails test` passed after shipping P2-03 Google Calendar connection, including `test/integration/google_calendar_connections_test.rb` with 6 tests and 51 assertions covering connection, disconnection, user-scoped state, and independent access between family members.
- 2026-03-24: `bin/rails test` passed after shipping P2-04 reminder calendar sync, including `test/integration/reminder_calendar_sync_test.rb` with 8 tests and 36 assertions covering reminder create with calendar metadata, reminder update patching same event, reminder clear deleting calendar event, failed sync preserving BabyVinci reminder, sync failure UI state, partial sync with mixed member connections, event ownership remaining with creator, and reminder save without calendar connection.
- 2026-03-25: `agent-browser` verified P2-04 on `http://127.0.0.1:3000`: new account creation, baby profile setup, setting reminder via 1-hour preset, reminder appearing in scheduled state, manually triggering sync failure state, and confirming the calm failure message displays correctly with "Calendar sync failed. Your reminder is saved in BabyVinci." and "Tap edit to try again." guidance.
- 2026-03-26: `bin/rails test` passed for all 81 tests including 8 new sleep tests (6 model tests, 4 integration tests) covering sleep creation, ending, validation, overlapping prevention, scope queries, and timeline rendering.
- 2026-03-26: `agent-browser` verified P3-01 on `http://127.0.0.1:3000`: Sleep button visible in sticky action bar, Start sleep form with time picker, active sleep card showing "Sleeping now" with live duration timer, End sleep button working inline, sticky bar transforming from "Sleep | Feed | Diaper" to "End sleep | Feed | Diaper", and completed sleep appearing in Timeline with timestamp.
- 2026-03-26: `bin/rails test` passed for all 81 tests with no regressions after P3-02 verification.
- 2026-03-26: `agent-browser` verified P3-02 on `http://127.0.0.1:3000`: Today clearly shows active sleep state with "Sleep status" header, "Now" label, "Sleeping now" text, live elapsed timer showing "Started 1 minute ago", and "End sleep →" button. When sleep ends, Today displays "Last sleep" card with duration (e.g., "52 min") and timestamp (e.g., "Today at 10:32 PM"). Sticky action bar correctly transforms from "Sleep | Feed | Diaper" to "End sleep | Feed | Diaper" during active sleep. Sleep state shares screen cleanly with feed, diaper, reminder, and timeline content.
- 2026-03-26: `bin/rails test` passed for all 100 tests including 19 new guidance tests covering age bucket selection, content loading, max 2 notes enforcement, edge cases (negative ages, ages beyond buckets), and Today page integration.
- 2026-03-26: `agent-browser` verified P3-03 on `http://127.0.0.1:3000`: "At this age" section now uses accordion/summary UI that expands/collapses on tap, saving screen space. Evidence-based content updated from AAP (American Academy of Pediatrics) and Stanford Medicine Children's Health research. For 6-day-old baby shows: "Breastfed babies typically feed 10-12 times per 24 hours. Bottle-fed babies usually eat every 2-3 hours. Both are normal." and "Newborns sleep about 16-17 hours per day, waking every few hours to eat. This is expected." Sources cited in code: AAP HealthyChildren.org (Dr. Sanjeev Jain, MD, FAAP & Dr. Maya Bunik, MD, MPH, FAAP) and Stanford Medicine Children's Health "Newborn Sleep Patterns". No dosage recommendations included per PRD "no medical theater" principle. Guidance section positioned after reminder card to keep reminders prominent. Accordion uses info icon and rotate chevron for clear affordance.
- 2026-03-27: `bin/rails test` passed for all 100 tests including 19 guidance tests covering all 8 age buckets (newborn, early_weeks, six_weeks, two_months, three_months, four_months, five_months, six_months). Guidance content is age-bucketed (0-196 days), evidence-based from AAP & Stanford Medicine, follows product tone rules (calm, supportive, non-diagnostic), with no medical advice or dosage recommendations. `agent-browser` verified P3-04 on `http://127.0.0.1:3000`: 7-day-old baby shows correct newborn bucket guidance with accordion expand/collapse working properly. All 16 guidance notes across 8 buckets verified in model. Sources cited: AAP HealthyChildren.org feeding guidance and Stanford Medicine Children's Health newborn sleep patterns.
- 2026-03-27: `bin/rails test` passed for all 142 tests including 23 new concern flow tests (5 model tests + 8 integration tests) and 7 doctor summary tests covering all 5 fixed concern flows (fever, too_sleepy, fewer_wet_diapers, breathing, vomiting), all three dispositions (watch_closely, call_pediatrician_today, seek_urgent_care_now), doctor summary with 24h/72h/7d windows, printable text format export, and timeline integration.
- 2026-03-27: `agent-browser` verified P4-01 through P4-04 on `http://127.0.0.1:3000`: Today page shows "Concerned?" section with "Check on something" entry point listing all 5 concern types (fever, too sleepy, fewer diapers, breathing, vomiting). Clicking fever flow completes all 3 questions and shows "Watch closely" disposition with calm copy "Keep watching and log if anything changes." Doctor summary page accessible from More, displays time windows (24h/72h/7d), event counts (13 feeds, 4 diapers, 7 sleeps, 1 concern), recent safety checks with concern title and disposition. More page shows both "Doctor visit" and "Recent concerns" sections with proper navigation.
- 2026-03-27: UI/UX fixes applied and verified: (1) Session state leak fixed - switching from fever flow (Q2/3) to breathing flow now correctly starts at Q1/2, (2) Multiselect questions now rendering - breathing flow shows all 7 checkbox options, (3) Disposition visual hierarchy improved - "call_pediatrician_today" uses caution amber, "seek_urgent_care_now" uses urgent red, "watch_closely" uses neutral, (4) Today page "Concerned?" section enhanced with left border for visibility, (5) Doctor summary time window selection improved with checkmark icon and stronger active state contrast. All 142 tests pass.

### Phase 1 tracker
- [x] P1-01 Parent sign up / sign in
- [x] P1-02 Create one baby profile
- [x] P1-03 Today dashboard
- [x] P1-04 Shared timeline
- [x] P1-05 Quick log: feed
- [x] P1-06 Quick log: diaper
- [x] P1-07 Edit and delete recent events
- [x] P1-08 Invite family members
- [x] P1-09 Mobile-first layout
- [x] P1-10 Phase 1 launch polish / QA

### Phase 2 tracker
- [x] P2-01 Shared next-feed reminder state
- [x] P2-02 Today reminder card
- [x] P2-03 Google Calendar connection
- [x] P2-04 Reminder calendar sync
- [x] P2-05 Reminder delivery polish / QA

### Phase 3 tracker
- [x] P3-01 Sleep start / end flow
- [x] P3-02 Today sleep state
- [x] P3-03 Guidance notes on Today
- [x] P3-04 Guidance content seeds

### Phase 4 tracker
- [x] P4-01 Fixed concern flows
- [x] P4-02 Initial concern content set
- [x] P4-03 Doctor summary export
- [x] P4-04 Recent concern results

### Phase 5 tracker
- [ ] P5-01 Android Hotwire Native shell
- [ ] P5-02 Android notification proof
- [ ] P5-03 Rails-managed shared push delivery
- [ ] P5-04 iOS Hotwire Native shell
- [ ] P5-05 iOS notification parity
- [ ] P5-06 Notification polish / family QA

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

- `PRD.md` is the canonical product spec, task contract source, and execution tracker.
- Phase 1 is the detailed launch target.
- Phases 2-4 are intentionally lighter until real-world use begins.
- Do not treat the full product scope as a prerequisite for launch.
- Build and verify in phase order unless an explicit decision changes priority.

## Task Contract Rules

- Every tracked task below must be executable from this document without inventing a separate quick task contract.
- If a task is ambiguous, clarify the task or update `PRD.md` before coding.
- Each task should define four things: contract, expected behavior, written test proof, and QA evidence.
- Completion proof for a PRD task is: code matches the task contract, written tests prove the core behavior, and `agent-browser` QA verifies the end-to-end flow.

---

## Scope

### In scope now (Phase 1 launch)
- Phase 1 is the launch target.
- It must be useful before any later-phase work begins.
- shared baby profile
- shared timeline of care events
- quick logging for feed and diaper
- Today screen with baby age, latest feed, latest diaper, and recent events
- invite family members up to 3 total people
- edit and delete recent events
- mobile-first web app

### Likely follow-on scope after launch
- shared next-feed reminders
- Google Calendar-backed reminder delivery
- sleep logging
- 1-2 age-based guidance notes on Today
- a small set of conservative concern flows
- printable doctor summary
- Hotwire Native Android and iOS shells for internal family testing
- app-owned next-feed notification delivery to every registered parent device
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
- one baby workspace supports up to 3 people in the main UX
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
- after each phase, the app must be usable immediately by the small family group sharing the baby log
- Phase 1 must be useful before installability, offline support, or advanced content systems are considered

---

## Privacy and Trust

- no public profiles, social graph, or third-party family sharing in v1
- up to 3 family members can access one baby workspace
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
- Another invited family member sees the new event quickly after refresh or revisit without confusion
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
- Invite family member
- Recent concern results
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
Single table for core logging and saved concern results.

Fields:
- id
- baby_id
- user_id
- kind (`feed`, `diaper` in Phase 1; add `sleep` only when Phase 3 starts; add `concern` in Phase 4)
- started_at
- ended_at nullable
- payload json
- created_at
- updated_at

Payload examples:
- feed: `{ mode: breast|bottle_breastmilk|formula, amount_ml?, side?, duration_min? }`
- diaper: `{ pee: true|false, poop: true|false, color? }`
- concern: `{ flow_key: fever, version: 1, answers: [...], disposition: call_pediatrician_today }`

### Model notes
- Keep `payload` portable across SQLite-backed environments; favor Rails `json` attributes and small structured values.
- Do not add future-phase tables until the active phase clearly needs them.
- Guidance can start as seeded content in code or YAML.
- Concern flows can start as fixed POROs or plain Ruby structures.
- Saved concern results should reuse `CareEvent` rather than a separate concern table.
- Do not add soft delete in the initial build unless a real product need appears.

---

## Delivery Phases

### Phase 1 — Shared Essential Logging MVP

#### Goal
Ship the minimum version that a small family group can use immediately for daily baby care.

#### Why this phase exists
This phase solves the core memory problem first.
Without this phase, the rest is decoration.

#### What ships
- parent sign up / sign in
- create one baby profile
- Today screen
- shared timeline
- quick log: feed
- quick log: diaper
- edit and delete recent events
- invite family members up to 3 total people
- mobile-first layout

#### Explicit exclusions in Phase 1
- sleep logging
- guidance cards
- concern flows
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
- As a parent, I can invite another family member once the app is already useful.

#### Task contracts

##### P1-01 Parent sign up / sign in
- Contract: A parent can create an account, sign in later, and land in the correct next step without confusion.
- Expected behavior:
  - Unauthenticated access to baby data routes redirects to sign in.
  - A first-time parent with no baby goes to baby creation after auth.
  - A returning parent with a baby goes to `Today` after auth.
  - Invalid auth attempts use calm error copy and do not expose whether an email exists.
- Written test proof:
  - Account creation succeeds.
  - Valid sign in succeeds.
  - Invalid sign in fails safely.
  - Post-auth redirect behavior matches setup state.
- QA evidence:
  - Create a new account in the browser.
  - Sign out and sign back in.
  - Confirm redirect behavior for first-time and returning states.

##### P1-02 Create one baby profile
- Contract: The first parent creates exactly one baby workspace for v1 and becomes its first parent member.
- Expected behavior:
  - Required baby fields are `first_name` and `birth_at`.
  - Successful creation immediately makes the baby workspace usable.
  - Main v1 UX does not allow creating a second baby.
  - The baby age label is available as soon as creation succeeds.
- Written test proof:
  - Baby creation creates the baby and membership.
  - Required field validation works.
  - Second-baby creation is blocked in the main flow.
- QA evidence:
  - Create a baby from a fresh account.
  - Confirm landing on a usable `Today` screen with baby identity visible.

##### P1-03 Today dashboard
- Contract: `Today` answers what matters now at a glance for a tired parent.
- Expected behavior:
  - Shows baby name, age label, time since last feed, time since last diaper, and the recent 8 timeline entries.
  - Sticky primary actions `Feed` and `Diaper` stay easy to reach on mobile.
  - Empty states stay useful and calm when no events exist yet.
  - Refresh or revisit shows the latest shared data without requiring interpretation.
- Written test proof:
  - Empty `Today` state renders.
  - Populated `Today` state renders the latest feed, diaper, and recent entries correctly.
  - Dashboard data is scoped to the signed-in parent's baby workspace.
- QA evidence:
  - Open `Today` before any logs exist.
  - Add logs and confirm the screen becomes immediately useful.

##### P1-04 Shared timeline
- Contract: Both parents can read a single shared reverse-chronological history without onboarding.
- Expected behavior:
  - Events are ordered newest first and grouped by day.
  - Each row shows timestamp, concise event summary, and author.
  - Only events for the shared baby are visible.
  - Tapping an event leads to edit/delete actions.
- Written test proof:
  - Timeline ordering is reverse chronological.
  - Day grouping is correct.
  - Event attribution is visible.
  - Membership scoping prevents access to other babies' data.
- QA evidence:
  - Log events from two different accounts and confirm both see the same timeline.

##### P1-05 Quick log: feed
- Contract: A parent can log a feed in one screen and one submit, fast enough for one-handed use.
- Expected behavior:
  - Timestamp defaults to `now`.
  - Only `mode` is required beyond timestamp.
  - Supported modes are `breast`, `bottle_breastmilk`, and `formula`.
  - Optional fields are `amount_ml`, `side`, and `duration_min` and may be left blank.
  - Save returns the parent to a useful context with the new feed visible.
  - Last-used mode may be preselected only when doing so is clearly safe.
- Written test proof:
  - A feed saves with only required fields.
  - Optional values persist when provided.
  - Missing `mode` shows validation failure.
- QA evidence:
  - Log a feed on a phone-width viewport in under 5 seconds.
  - Refresh another parent session and confirm the feed appears.

##### P1-06 Quick log: diaper
- Contract: A parent can log a diaper faster than opening Notes.
- Expected behavior:
  - Timestamp defaults to `now`.
  - Required diaper type is `wet`, `poop`, or `both` and should be selectable in one tap.
  - Optional poop color note may be left blank.
  - Save returns the parent to a useful context with the new diaper visible.
- Written test proof:
  - `wet`, `poop`, and `both` diaper events save correctly.
  - Missing type shows validation failure.
  - Optional note persists when provided.
- QA evidence:
  - Log each diaper type and confirm the timeline summary is clear.

##### P1-07 Edit and delete recent events
- Contract: Either parent can correct mistaken shared events without confusion.
- Expected behavior:
  - Both parents can edit and delete Phase 1 shared care events.
  - Edit uses the same core fields as the create flow for that event type.
  - Delete requires a clear confirmation step to avoid accidental loss.
  - After edit or delete, `Today` and `Timeline` reflect the updated state on refresh or redirect.
- Written test proof:
  - Authorized parents can edit shared events.
  - Authorized parents can delete shared events.
  - Non-members cannot modify events.
- QA evidence:
  - Edit one feed or diaper event.
  - Delete one event and confirm the removal is reflected everywhere.

##### P1-08 Invite family members
- Contract: A signed-in member can invite additional family members into the same baby workspace until the baby log has 3 total people.
- Expected behavior:
  - Invite is email-based and works for any invited family member.
  - Invitation tokens are single-use and expire.
  - The invited family member can accept the invite and join the existing baby workspace.
  - All members have equal permissions after acceptance.
  - A fourth person cannot be added through the main v1 UX.
  - Reopening a used or expired invite shows a calm, clear dead-end state.
- Written test proof:
  - Invite creation works for an eligible workspace.
  - Invite acceptance adds the invited family member to the correct baby.
  - Used or expired invites are rejected.
  - Membership limit stays at 3 people.
- QA evidence:
  - Send the invite from member A.
  - Accept it from a separate browser or device as member B.
  - Send another invite from an existing member.
  - Accept it from a separate browser or device as member C.
  - Confirm all 3 members see the same existing and newly created events.

##### P1-09 Mobile-first layout
- Contract: All Phase 1 flows remain usable in a mobile browser with one hand and no installation.
- Expected behavior:
  - Core screens work cleanly at common phone widths from 320px to 430px.
  - No horizontal scrolling is required for primary flows.
  - Tap targets for primary actions feel generous.
  - Feed and diaper actions remain easy to reach from the primary surfaces.
- Written test proof:
  - Core routes render the expected mobile-first surfaces and actions.
  - Layout-critical regressions are covered by written tests where practical; end-to-end mobile QA remains mandatory.
- QA evidence:
  - Verify `Today`, `Timeline`, feed, diaper, invite, and `More` on common phone widths with `agent-browser`.

##### P1-10 Phase 1 launch polish / QA
- Contract: Phase 1 is only complete when the full shared-family daily flow is proven end to end.
- Expected behavior:
  - Empty and populated states both feel calm and usable.
  - Errors are recoverable and do not trap the parent.
  - Navigation has no dead ends in the shipped Phase 1 flows.
  - All Phase 1 acceptance criteria are demonstrably satisfied.
- Written test proof:
  - All written tests covering Phase 1 behavior pass.
- QA evidence:
  - Run the full Phase 1 checklist end to end with `agent-browser` and record contract evidence against the Phase 1 tasks.

#### Phase acceptance criteria
- A single parent can create an account, create a baby, and log the first event without inviting anyone first.
- Two separate accounts can see the same baby data.
- A feed can be logged in under 5 seconds on mobile.
- A diaper can be logged in under 5 seconds on mobile.
- Another shared family member can understand the last 12 hours in under 10 seconds.
- The timeline is understandable with no onboarding needed.
- The app is useful in a mobile browser without installation.

#### Phase QA / verification

### Manual QA checklist
- Verification proof for this change: complete the same flow with 3 separate accounts and confirm the third invited family member can see existing events and log a new one that appears for the original member after refresh.
- Create parent A account.
- Create baby.
- Log a feed before inviting anyone else.
- Log a diaper before inviting anyone else.
- Invite family member B.
- Accept invite from a different browser/device.
- Refresh or revisit and confirm family member B sees the existing feed.
- Log diaper from family member B.
- Refresh or revisit and confirm parent A sees the new diaper.
- Invite family member C.
- Accept invite from a different browser/device.
- Refresh or revisit and confirm family member C sees the existing feed and diaper.
- Log feed or diaper from family member C.
- Refresh or revisit and confirm parent A sees the new event.
- Edit an event.
- Delete an event.
- Verify age label shows correctly.
- Verify mobile layout on common phone widths.

### Edge cases
- Invite is sent later, not during first session.
- An invited family member opens invite twice.
- Network interruption on save.
- Two events logged close together.
- Optional fields left blank.

#### Release check
If this phase is done, the app is already useful.
The parents can use it as a shared memory system immediately.

---

### Phase 2 — Shared Reminders + Calendar Sync

#### Goal
Make the app proactive in the simplest possible way by helping parents remember what should happen next and delivering reminders through tools they already trust.

#### Why this phase exists
Logging alone is helpful, but handoff moments still break down when nobody knows what is supposed to happen next.

This phase solves that with a shared next-feed reminder first, then makes it useful in real life by mirroring it into each parent's Google Calendar.

#### What ships
- shared next-feed reminder on Today
- per-user Google Calendar connection
- one-way reminder sync from BabyVinci to connected calendars
- calm reminder sync states and failure handling

#### Keep it simple
- BabyVinci stays the source of truth
- Google Calendar is a delivery surface, not the primary data model
- sync is one-way only; do not import calendar edits back into the app
- Google is the only calendar provider in the first version
- no recurring schedules in the first version
- appointments can reuse this foundation later, but Phase 2 should stay reminder-focused

#### Task contracts

##### P2-01 Shared next-feed reminder state
- Contract: A parent can set, see, change, or clear one shared reminder for the next feed directly from the shared baby workspace.
- Expected behavior:
  - Only one active next-feed reminder can exist per baby.
  - The reminder stores a target time and is visible to every shared member of that baby workspace.
  - Any shared member can replace the current reminder with a new time.
  - Any shared member can clear the reminder once it is no longer useful.
  - If the reminder time passes, it remains visible as overdue until changed or cleared.
- Written test proof:
  - Setting a reminder stores one shared reminder for the signed-in parent's baby workspace.
  - Updating the reminder replaces the previous time instead of creating duplicates.
  - Clearing the reminder removes the shared reminder state.
  - Reminder access remains scoped to the correct baby workspace.
- QA evidence:
  - Set a reminder from one account and confirm it appears.
  - Refresh another member session and confirm the same reminder appears there.
  - Replace the reminder and confirm both members now see the updated time.
  - Clear the reminder and confirm the state resets.

##### P2-02 Today reminder card
- Contract: `Today` exposes the shared next-feed reminder in place of the low-value `What matters now` card.
- Expected behavior:
  - When no reminder is set, the card shows a calm empty state.
  - The card offers quick presets such as `30 min`, `1 hour`, `2 hours`, and `3 hours`.
  - The card also allows setting an exact reminder time when needed.
  - When a reminder is active, the card shows the target time and a relative label.
  - When a reminder is overdue, the card clearly says so without panic language.
  - The card supports replace and clear actions without sending the parent into a separate management flow.
- Written test proof:
  - Empty, active, and overdue reminder states render on `Today`.
  - Quick preset actions render.
  - Exact reminder time entry renders.
- QA evidence:
  - Open `Today` with no reminder set.
  - Set a reminder from the card using a preset.
  - Replace it with a manual time.
  - Confirm the overdue state stays understandable.

##### P2-03 Google Calendar connection
- Contract: Each parent can connect or disconnect their own Google Calendar account without affecting other shared members.
- Expected behavior:
  - Connection lives at the user level, not the baby level.
  - A parent can connect a Google account from `More` or `Settings`.
  - Connected state is visible and calm.
  - Disconnecting stops future calendar sync for that parent.
  - The reminder feature still works even if no calendar is connected.
- Written test proof:
  - A user can connect a Google Calendar account.
  - A user can disconnect it safely.
  - Connection state is scoped to the current user.
- QA evidence:
  - Connect one parent's Google account.
  - Confirm another parent does not appear connected automatically.
  - Disconnect and confirm the app returns to a disconnected state.

##### P2-04 Reminder calendar sync
- Contract: When a parent sets a reminder, BabyVinci creates a single calendar event hosted in that parent's Google Calendar and invites all connected family members as attendees so everyone receives notifications.
- Expected behavior:
  - Setting a reminder creates one calendar event in the creating parent's Google Calendar.
  - All family members with connected calendars are added as attendees with forced notifications (`sendNotifications: true`).
  - Family members without connected calendars do not block the sync (partial sync).
  - Updating the reminder updates the existing event (same event ID) instead of creating duplicates.
  - Clearing the reminder deletes the calendar event.
  - The event uses calm, practical copy and the reminder time from BabyVinci.
  - Calendar sync failures do not block saving the in-app reminder.
  - If sync fails, the app shows a calm sync-state message so parents understand the reminder still exists in BabyVinci.
  - Event ownership remains with the creating parent (no transfer on edit by others).
- Written test proof:
  - Reminder create generates one calendar event with multiple attendees.
  - Reminder update patches the same event without creating duplicates.
  - Reminder clear deletes the event.
  - A failed calendar sync does not lose the BabyVinci reminder.
  - Partial sync works when only some family members have connected calendars.
- QA evidence:
  - Connect two parents' Google Calendar accounts.
  - Parent A sets a reminder and confirms one calendar event appears in Parent A's calendar with Parent B as attendee.
  - Verify both parents receive notifications on their devices.
  - Parent B updates the reminder and confirm the same event is updated.
  - Clear the reminder and confirm the calendar event disappears for both parents.
  - Verify partial sync by testing with only one parent connected.

##### P2-05 Reminder delivery polish / QA
- Contract: Phase 2 is only complete when the reminder flow is understandable end to end for shared parents and practical on a real phone.
- Expected behavior:
  - Reminder copy stays calm and short.
  - Reminder and sync states never hide the shared app state.
  - A parent can understand whether the reminder exists in BabyVinci, whether calendar sync is connected, and what to do next if sync fails.
  - The flow stays useful even when only one parent has Google Calendar connected.
- Written test proof:
  - Core reminder and calendar-sync written tests pass.
- QA evidence:
  - Run the full shared reminder flow with two accounts.
  - Verify at least one connected phone receives the mirrored calendar reminder in normal use.
  - Verify the reminder still remains visible in BabyVinci if calendar sync is unavailable.

#### Acceptance criteria
- Parent can set, change, and clear one shared next-feed reminder from `Today` in a few taps.
- Both parents see the same reminder state after refresh or revisit.
- Setting a reminder creates one calendar event with all connected family members as attendees (forced notifications).
- Family members without calendar connections do not block sync for connected members.
- Updating the reminder updates the same calendar event (no duplicates).
- Clearing the reminder removes the calendar event for all attendees.
- The shared in-app reminder still works even if calendar sync fails or is not connected.

#### QA / verification
- Set a next-feed reminder, refresh another shared session, and confirm both parents see the same state.
- Verify empty, active, and overdue reminder states on `Today`.
- Connect two parents' Google Calendar accounts.
- Set a reminder from Parent A and confirm:
  - One event appears in Parent A's calendar
  - Parent B receives an invitation/notification
  - Both parents get device notifications at reminder time
- Update the reminder from Parent B and confirm the same event is updated (check event ID unchanged).
- Clear the reminder and confirm the event is removed from both parents' calendars.
- Verify partial sync by disconnecting Parent B, setting a reminder from Parent A, and confirming it still syncs to Parent A's calendar.
- Verify the reminder still exists in BabyVinci when calendar sync fails.

#### Release check
If this phase is done, the app becomes more than a shared memory system.
It helps parents remember what is next and delivers that reminder through the tools already on their phones.

---

### Phase 3 — Sleep + Age-Based Guidance

#### Goal
Make the app feel like a calm companion, not only a logger.

#### Why this phase exists
Once reminder delivery is useful, the next step is helping parents understand sleep state and what matters at the current age.

#### What ships
- sleep start / sleep end
- Today shows active sleep state or latest sleep
- Today shows up to 2 short age-based guidance notes

#### Keep it simple
- no guidance CMS required at first
- guidance can be seeded by age buckets in code or YAML
- one active sleep max per baby
- no wake-window coaching or sleep analytics

#### Task contracts

##### P3-01 Sleep start / end flow
- Contract: A parent can start sleep and end that same sleep later without extra setup or interpretation.
- Expected behavior:
  - Start defaults to `now`.
  - End resolves the current active sleep for the baby.
  - Completed sleeps can be corrected later by editing start and end times.
  - Active sleeps can correct the start time without exposing direct end-time editing.
  - Any sleep can be deleted if it was logged by mistake.
  - Only one active sleep can exist at a time.
  - Overlapping active sleeps are blocked.
- Written test proof:
  - Sleep start creates one active sleep.
  - Sleep end closes the active sleep correctly.
  - A second active sleep cannot start while one is open.
  - Completed sleeps can be edited without reopening them.
  - Active sleeps can update the start time without bypassing the end flow.
  - Active and completed sleeps can be deleted cleanly.
- QA evidence:
  - Start sleep, refresh, and confirm it stays active.
  - End sleep and confirm the result looks correct.
  - Edit one completed sleep and confirm the updated time and duration look correct.
  - Delete one mistaken sleep and confirm `Today` and `Timeline` both update.

##### P3-02 Today sleep state
- Contract: `Today` clearly shows whether the baby is sleeping now or what the latest sleep was.
- Expected behavior:
  - Active sleep state is prominent and calm.
  - If no sleep is active, `Today` shows the latest completed sleep summary.
  - Sleep state shares the screen cleanly with feed, diaper, reminder, and timeline content.
- Written test proof:
  - `Today` renders active-sleep and recent-sleep states correctly.
  - Sleep state is scoped to the correct baby workspace.
- QA evidence:
  - Verify `Today` before starting sleep, during active sleep, and after ending sleep.

##### P3-03 Guidance notes on Today
- Contract: `Today` shows up to two short age-relevant guidance notes without making the screen feel crowded.
- Expected behavior:
  - Guidance is short, supportive, and non-diagnostic.
  - Zero to two notes may display depending on the age bucket.
  - Guidance remains useful even when logging is incomplete.
- Written test proof:
  - Age-bucket selection works.
  - No more than two notes render.
- QA evidence:
  - Change baby age and confirm the visible guidance updates.

##### P3-04 Guidance content seeds
- Contract: Phase 3 ships with a tiny curated guidance set that can live in code or YAML until proven insufficient.
- Expected behavior:
  - Guidance content is age-bucketed and easy to review.
  - Missing or unused content does not break `Today`.
  - Copy follows the product tone rules.
  - Content is evidence-based from reputable pediatric sources (AAP, Stanford Medicine).
- Written test proof:
  - Seeded guidance content loads for the defined age buckets.
  - Missing-content handling fails safely.
- QA evidence:
  - Spot-check each seeded age bucket in the browser.
- Research basis:
  - AAP HealthyChildren.org: "How Often and How Much Should Your Baby Eat?" by Dr. Sanjeev Jain, MD, FAAP & Dr. Maya Bunik, MD, MPH, FAAP (AAP Section on Breastfeeding Chair)
  - Stanford Medicine Children's Health: "Newborn Sleep Patterns"
  - AAP Well-Child Visit Schedule for milestone timing
  - No specific dosage recommendations (per pediatrician discretion and PRD "no medical theater" principle)

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

### Phase 4 — Concern Flows + Doctor Summary Export

#### Goal
Add the highest-leverage support feature without pretending to be a doctor.

#### Why this phase exists
This phase addresses the real parent fear loop: “Is this normal or do we need help?”

#### What ships
- primary concern entry point from `Today`
- secondary concern entry point from `More`
- exactly 5 fixed concern flows with reviewed copy
- compact recent concern results
- dispositions: watch closely, call pediatrician today, seek urgent care now
- printable web summary for the selected baby's recent history

#### Keep it simple
- no freeform AI triage
- no open-ended symptom parser
- no generic workflow builder required at first
- printable HTML first; add PDF only if the web version proves insufficient
- keep concern results in the existing care-event record shape

#### Exact concern set
- fever / feels too hot
- too sleepy to feed / hard to wake
- fewer wet diapers / dehydration concern
- trouble breathing / breathing seems wrong
- repeated vomiting / not keeping feeds down

#### Task contracts

##### P4-01 Fixed concern flows
- Contract: A parent can start one of the exact concern flows from `Today` in under two taps and always reach a clear next step.
- Expected behavior:
  - Concern flows are finite and rules-based.
  - `Today` is the primary entry point; `More` is secondary.
  - Freeform symptom text is never the primary input.
  - Every path ends in `watch closely`, `call pediatrician today`, or `seek urgent care now`.
- Written test proof:
  - Every answer path resolves to a valid disposition.
  - Invalid or incomplete states cannot bypass the flow.
  - The primary entry point routes to the right exact flow.
- QA evidence:
  - Run every exact concern flow from `Today` end to end.

##### P4-02 Initial concern content set
- Contract: Phase 4 ships exactly the concern set above.
- Expected behavior:
  - Each flow has reviewed opening copy, a short answer path, and a disposition.
  - The set is intentionally small and does not try to be comprehensive.
  - Copy avoids diagnosis language and false certainty.
  - Urgent outcomes end with a plain action statement.
- Written test proof:
  - Each required concern definition is present and structurally valid.
  - Each concern maps to one of the three dispositions.
  - Missing or disabled content fails safely.
- QA evidence:
  - Spot-check each concern and verify the result copy stays calm and explicit.

##### P4-03 Doctor summary export
- Contract: A parent can generate a printable recent-history summary that is useful in a clinic visit.
- Expected behavior:
  - Export contains only the selected baby's data.
  - Default window is last 72 hours.
  - 24-hour and 7-day windows are available.
  - Event counts and recent-history details are understandable to a parent.
  - Printable HTML is sufficient unless proven otherwise.
- Written test proof:
  - Export data is correctly scoped and counted.
  - Default and alternate time windows render the expected events.
- QA evidence:
  - Generate exports for 24h, 72h, and 7d windows and review them in the browser.

##### P4-04 Recent concern results
- Contract: A parent can revisit past concern outcomes from a compact recent-results list without rerunning the flow.
- Expected behavior:
  - Saved results show concern type, time, and disposition.
  - History is scoped to the shared baby and ordered newest first.
  - The list is compact and lives under `More`.
  - Past results are readable without re-entering answers.
- Written test proof:
  - Concern results persist.
  - History ordering and baby scoping are correct.
  - The compact list renders with the expected fields.
- QA evidence:
  - Complete concern flows and revisit their saved results from `More`.

#### Acceptance criteria
- Parent can start a concern flow in under 2 taps from `Today`.
- The shipped concern set is exact and finite.
- Concern flows never accept freeform symptom text as primary input.
- Concern results are saved and re-readable without rerunning the flow.
- Export defaults to last 72 hours and remains useful for a clinic visit.
- Every concern ends with a clear next step.

#### QA / verification
- Run each exact concern flow from start to finish.
- Verify every answer path ends in a valid disposition.
- Verify the compact recent-results list shows the saved concern.
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

### Phase 5 — Hotwire Native + Custom Notifications

#### Goal
Ship thin Hotwire Native shells and BabyVinci-owned next-feed notifications that reach every registered family device.

#### Why this phase exists
The app already proves shared reminder value, but delivery still depends on external tools.

This phase makes reminder delivery feel like BabyVinci itself while keeping the product web-first and small.

#### What ships
- Android Hotwire Native shell for internal testing
- Android notification proof using the BabyVinci reminder flow
- Rails-managed push delivery for shared next-feed reminders
- iOS Hotwire Native shell distributed for internal family testing
- iOS notification parity using the same shared reminder backend
- notification deep links, permission states, and calm failure handling

#### Keep it simple
- keep the product web-first; existing Rails routes remain the primary UI
- use Hotwire Native shells, not a React or fully native rewrite
- internal testing only; do not expand this phase into public store release work
- Rails remains the source of truth for reminder state and notification scheduling
- prefer one push backend path that can serve Android now and iOS later
- no badges, marketing pushes, or broad notification settings matrix
- no offline queue work in this phase
- each P5 task must fit in one opencode session and be manually verifiable by the product owner

#### Task contracts

##### P5-01 Android Hotwire Native shell
- Contract: The existing BabyVinci Rails app runs inside a thin Android Hotwire Native shell that is usable for daily family testing.
- Expected behavior:
  - Sign in, Today, Timeline, More, and existing form flows work inside the Android shell.
  - The shell uses path configuration so presentation rules can evolve without rewriting the app.
  - The shell can open a BabyVinci URL from a notification tap and land in useful context.
  - The Android build can be installed by the product owner for internal testing.
- Written test proof:
  - Any Rails changes needed for native entry or deep-link support are covered by written tests.
  - The Android project includes at least one automated smoke check for app launch or path configuration loading.
- QA evidence:
  - Install the Android app on a real phone.
  - Sign in, navigate Today / Timeline / More, log a feed, and set a reminder.

##### P5-02 Android notification proof
- Contract: On Android, BabyVinci can trigger a branded next-feed notification from the existing reminder flow, proving permission, copy, and deep-link behavior before cross-device push rollout is complete.
- Expected behavior:
  - The reminder flow can request notification permission with calm copy where required.
  - Setting a reminder can schedule one Android notification tied to BabyVinci reminder state.
  - Tapping the notification opens the app to a useful reminder context.
  - Editing or clearing the reminder on that device prevents stale future notifications.
  - This task may use a temporary Android-only path; shared multi-device correctness is completed in P5-03 and later tasks.
- Written test proof:
  - Any Rails changes needed for notification payloads or deep links are covered by written tests.
  - Android automated coverage exists for scheduling or canceling the reminder notification where practical.
- QA evidence:
  - Set a reminder on Android, lock the phone, receive the notification, tap it, then edit and clear the reminder and verify stale delivery does not survive on that device.

##### P5-03 Rails-managed shared push delivery
- Contract: BabyVinci owns reminder delivery for every registered family device by scheduling push notifications from Rails whenever shared reminder state changes.
- Expected behavior:
  - Device installs and push tokens are stored per app install, not just per user.
  - Creating, updating, or clearing the shared next-feed reminder schedules or cancels push delivery from Rails.
  - The backend is ready to fan out to Android and iOS devices using one shared reminder model.
  - Repeated reminder edits do not create duplicate future deliveries.
  - Notification send failures never remove the shared in-app reminder.
  - Google Calendar may remain as fallback during rollout, but it is no longer the required primary delivery path.
- Written test proof:
  - Device registration is scoped correctly to users and installs.
  - Reminder create, update, and clear behavior schedules or cancels push work correctly.
  - Duplicate suppression is covered for repeated reminder changes.
  - A failed push send does not lose BabyVinci reminder state.
- QA evidence:
  - Register at least one Android device, set a reminder, verify server-driven delivery, then update and clear the reminder and confirm the notification behavior follows the latest shared state.

##### P5-04 iOS Hotwire Native shell
- Contract: The existing BabyVinci Rails app runs inside a thin iOS Hotwire Native shell that can be distributed to the family for internal testing.
- Expected behavior:
  - Sign in, Today, Timeline, More, and existing form flows work inside the iOS shell.
  - The shell can open BabyVinci URLs from notification taps.
  - Distribution is internal-testing friendly, with no requirement for public App Store release in this phase.
  - The family has a workable installation path for iPhone testing, such as TestFlight.
- Written test proof:
  - Any Rails changes needed for iOS native entry or deep-link support are covered by written tests.
  - The iOS project includes at least one automated smoke check for app launch or path configuration loading.
- QA evidence:
  - Install the iOS app on a real iPhone, sign in, navigate Today / Timeline / More, log a feed, and set a reminder.

##### P5-05 iOS notification parity
- Contract: iPhone devices can receive BabyVinci next-feed notifications from the same Rails-managed shared reminder system used by Android.
- Expected behavior:
  - iOS notification permission flow is calm and recoverable.
  - The shared reminder backend can send to registered iPhone devices as well as Android devices.
  - Tapping the notification opens the app to a useful reminder context.
  - Editing or clearing the shared reminder prevents stale future notifications on registered iPhones.
  - Android and iOS stay on one shared notification model rather than separate reminder systems.
- Written test proof:
  - Mixed-platform device registration and fanout behavior are covered by written tests.
  - Reminder job tests include Android and iOS installs for the same baby workspace.
- QA evidence:
  - Install the iOS build on at least one family iPhone, set, update, and clear reminders, and verify delivery follows the latest shared state.

##### P5-06 Notification polish / family QA
- Contract: Phase 5 is only complete when the real family group can install the internal builds and trust reminder delivery across their actual phones.
- Expected behavior:
  - All family members can install the internal Android or iOS builds available to them.
  - Notification copy stays short, calm, and clearly owned by BabyVinci.
  - Notification taps always land in useful context.
  - Permission-denied and temporarily unavailable states explain what happened and what to do next.
  - The final flow avoids duplicate or contradictory notifications in normal reminder edits.
- Written test proof:
  - Core Rails tests, push scheduling tests, and native smoke checks all pass.
- QA evidence:
  - Verify the full family flow on one Android phone and two iPhones: create a reminder, update it from another account, clear it from a third account, and confirm delivery and in-app state stay understandable on each device.

#### Acceptance criteria
- The existing BabyVinci Rails product is usable inside thin Android and iOS Hotwire Native shells.
- A shared next-feed reminder can notify every registered family device.
- Editing or clearing a reminder keeps future delivery aligned with the latest shared reminder state.
- Notification taps open BabyVinci into useful context instead of a dead end.
- The family can install internal builds without requiring a public store launch.

#### QA / verification
- Install the Android shell and verify the existing core Rails flows work normally.
- Verify Android notification permission, delivery, tap behavior, update behavior, and clear behavior.
- Install the iOS shell and verify the existing core Rails flows work normally.
- Verify iOS notification permission, delivery, tap behavior, update behavior, and clear behavior.
- Run one real family shared-reminder test across the product owner's Android phone and two family iPhones.
- Confirm reminder edits do not leave duplicate or stale notifications queued.

#### Release check
If this phase is done, BabyVinci becomes an installable private family app with app-owned reminder delivery on the real family devices that use it.

#### Archived / deferred ideas
- appointments
- milestones
- offline core event queue
- pending sync and retry UX
- Revisit these only if real family use proves they matter more than notification reliability or shell polish.

---

## Recommended Build Order Inside Rails

### Suggested order
1. auth + baby creation
2. care event model + timeline
3. Today dashboard queries
4. feed and diaper forms
5. invite family members
6. shared next-feed reminder state + Today card if Phase 2 starts
7. Google Calendar connection + one-way reminder sync if Phase 2 starts
8. sleep state logic if Phase 3 starts
9. seeded guidance notes if Phase 3 starts
10. fixed concern flows + recent concern results if Phase 4 starts
11. printable export view if Phase 4 starts
12. Android Hotwire Native shell + Android notification proof if Phase 5 starts
13. Rails-managed shared push delivery + iOS shell + iOS parity if Phase 5 starts
14. appointments, milestones, and offline only after real use proves they matter

### Keep implementation boring
Prefer:
- conventional controllers
- small POROs for concern logic when Phase 4 starts
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
- `/concerns`
- `/summary`

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

### Risk 6: concern scope creep
Response:
- exact finite flows only
- compact recent-results list instead of a workflow builder
- printable HTML first

---

## Launch Recommendation

### Fastest path to real use
Ship in this order:
1. Phase 1
2. Phase 2
3. Phase 3
4. Phase 4
5. Phase 5

Do not wait for all phases.
Use it yourselves starting at Phase 1.

### Why
- Phase 1 already solves a real pain
- Phase 2 adds practical reminders without splitting the product across multiple apps
- Phase 3 makes it feel meaningfully better day to day
- Phase 4 adds trust and utility
- Phase 5 turns the web app into a private family app with BabyVinci-owned reminder delivery without forcing a rewrite

---

## Final Product Boundary

If a feature does not make one of these better, reject it:
- shared memory
- current-age guidance
- clear next step for concern
- better doctor conversation

That is the product.
