# BabyVinci

> **Built while my newborn slept.** I started this project the day I became a father — coding in the hospital during those precious quiet moments when baby was napping. Born from the chaos of night shifts and handoff confusion, this is the app I wish we'd had from hour one.

A shared baby tracking app for two sleep-deprived co-parents. Designed for use in complete darkness with one hand.

---

**Quick Pitch:** BabyVinci eliminates information asymmetry during shift handoffs. When one parent wakes up at 3 AM to take over, they instantly see: last feed, last diaper, is baby sleeping now, and what's next — no questions needed, no waking the other parent.

## What is BabyVinci?

BabyVinci solves the core problem of **information asymmetry** during shift handoffs between new parents. When one parent wakes up at 3 AM to take over, they need to know instantly: when was the last feed? Last diaper? Is baby sleeping now?

**Key Principles:**
- Calm over clever — reduces stress, doesn't create more
- One-hand use first — every core action possible while holding a baby
- Shared by both parents — both see the same timeline in real-time
- Mobile web first — fast deployment, no store delays
- No medical theater — guides and escalates, never diagnoses

## Current Features (Phase 1-4 Complete)

### Core Tracking
- ✅ **Quick logging** — Feed (breast/bottle/formula), Diaper (wet/poop/both), Sleep (start/end timer)
- ✅ **Today dashboard** — Shows baby's age, last feed time, last diaper, active sleep status, recent timeline
- ✅ **Shared timeline** — Reverse-chronological history visible to all family members
- ✅ **Edit & delete** — Correct mistakes without confusion

### Family Sharing
- ✅ **Up to 3 members** per baby workspace
- ✅ **Email-based invites** — Single-use, expiring tokens
- ✅ **Equal permissions** — All members can log and view

### Reminders & Calendar
- ✅ **Shared next-feed reminder** — Set, update, clear from Today screen
- ✅ **Quick presets** — 30 min, 1 hour, 2 hours, 3 hours
- ✅ **Google Calendar sync** — One-way sync with attendee notifications
- ✅ **Graceful failure handling** — Reminder stays in app even if sync fails

### Sleep & Guidance
- ✅ **Sleep start/end flow** — One active sleep max, live duration timer
- ✅ **Today sleep state** — Shows "Sleeping now" with elapsed time or last sleep summary
- ✅ **Age-based guidance** — 2 short evidence-based notes from AAP & Stanford Medicine
- ✅ **8 age buckets** — Newborn through 6 months

### Safety & Concern Flows
- ✅ **5 fixed concern flows** — Fever, too sleepy, fewer diapers, breathing issues, vomiting
- ✅ **3 dispositions** — Watch closely, call pediatrician today, seek urgent care now
- ✅ **Recent concerns list** — Compact history under More
- ✅ **Doctor summary export** — 24h/72h/7d printable summaries for clinic visits

## Tech Stack

- **Framework:** Rails 8
- **Frontend:** Hotwire (Turbo + Stimulus), Tailwind CSS
- **Database:** SQLite (development, test, and production)
- **Deployment:** Kamal on Hetzner VPS
- **Architecture:** Vanilla Rails — simple solutions first, complexity is a last resort

## Design System

BabyVinci uses **"Clinical Calm"** — a calm, serious, information-led mobile UI:

- **Colors:** Soft blue-green canvas, deep teal accents, white surfaces
- **Typography:** Sora (headings), IBM Plex Sans (body)
- **Layout:** Mobile-first, giant tap targets, minimal typing
- **Tone:** Calm, short, clear, practical — written for a tired parent at 3 AM

See [DESIGN.md](DESIGN.md) for complete design tokens and screen blueprints.

## Local Setup

```bash
# Install dependencies
bundle install

# Setup database
bin/rails db:migrate

# Run the development server
bin/dev
```

The app will be available at `http://localhost:3000`.

## Testing

```bash
# Run all tests
bin/rails test

# Run specific test files
bin/rails test test/integration/baby_invites_test.rb
```

We use:
- Integration tests for user flows
- Controller tests for HTTP behavior
- Model tests for business logic
- `agent-browser` for end-to-end verification

## Production Database Sync

```bash
bin/pull-production-db
```

This script:
1. Snapshots production SQLite via `bin/kamal`
2. Backs up your local database
3. Replaces `storage/development.sqlite3`

## Project Status

**Current Phase:** Phase 5 — Hotwire Native + Custom Notifications
**Last Updated:** March 28, 2026

### Completed Phases
- ✅ **Phase 1:** Shared Essential Logging MVP
- ✅ **Phase 2:** Shared Reminders + Calendar Sync
- ✅ **Phase 3:** Sleep + Age-Based Guidance
- ✅ **Phase 4:** Concern Flows + Doctor Summary Export

### In Progress
- 🔄 **Phase 5:** Hotwire Native shells (Android/iOS) with custom push notifications

## Documentation

- **[PRD.md](PRD.md)** — Complete product spec, feature contracts, and progress tracker
- **[DESIGN.md](DESIGN.md)** — UI/UX design system, tokens, and screen blueprints
- **[AGENTS.md](AGENTS.md)** — Development guidelines for AI coding agents
- **[FINDINGS.md](FINDINGS.md)** — First-year infant research and competitive analysis

## Target Users

- Primary: Mother and Father/Partner
- Context: Sleep-deprived, often one-handed, frequently interrupted, anxious about normalcy
- Assumptions: One household, one baby (v1), separate accounts with shared records

## Why BabyVinci Exists

Existing baby apps fail at the most important thing: **reliable real-time sharing** between parents. They:
- Have broken sync (iCloud-based, requires same Apple ID)
- Require too many taps for simple logging
- Amplify anxiety with gamification and metrics
- Treat dark mode as an afterthought

BabyVinci is built for the reality: 3 AM, exhausted, one hand free, in the dark, needing answers in under 10 seconds.

---

**Built with care for new parents everywhere.**
