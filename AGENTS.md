# AGENTS.md

This file provides guidance to AI coding assistants working with code in this repository.

## What is Vinci?

A newborn tracking app for co-parents, designed for use in complete darkness with one hand. The core problem: eliminating information asymmetry during shift handoffs between sleep-deprived parents. See PRD.md for full requirements and TODO.md for current progress.

## Development Server

Always assume a Rails development server is running on `localhost:3000`. No need to start/stop servers during development.

## Commands

```bash
# Development
bin/dev                          # Start Rails + Tailwind watcher (uses Foreman)
bin/rails server                 # Start Rails only

# Testing
bin/rails test                   # Run unit/functional tests
bin/rails test test/models/user_test.rb          # Single test file
bin/rails test test/models/user_test.rb:14       # Single test at line
bin/rails test:system            # System tests (Capybara + Selenium/Chrome)

# Linting & Security
bin/rubocop                      # Lint (rubocop-rails-omakase style)
bin/rubocop -a                   # Lint with auto-fix
bin/brakeman --no-pager          # Security scan
bin/importmap audit              # JS dependency audit

# Database
bin/rails db:prepare             # Create + migrate
bin/rails db:migrate             # Run pending migrations

# CI runs all checks: brakeman, importmap audit, rubocop, db:test:prepare + test + test:system
```

## Architecture

**Stack**: Rails 8, PostgreSQL, Hotwire (Turbo + Stimulus), TailwindCSS, Importmap (no JS bundler), Propshaft, Solid Queue/Cache/Cable (no Redis), Kamal deployment.

**Multi-tenancy**: Simple family-based scoping — all queries filter through `current_user.family`. No multi-tenant gem; only 2 users per family.

**Data model** (Delegated Types):
```
Family → Users (parents) + Babies → Activities
Activity subtypes: Feeding, Diaper, Sleep, Pumping, Health
```

**Current state**: Early Phase 1 — Rails scaffold + PostgreSQL + prototypes exist. Core models and auth are not yet built. Routes currently point to `/prototypes` for UI testing.

## UX Constraints

These are hard requirements, not suggestions:

- **Night mode only**: Dark grey (#121212) background, off-white (#E0E0E0) text, zero blue light, no pure black/white
- **One-handed operation**: All primary actions in bottom third (thumb zone), minimum 48px tap targets
- **<10 second task completion**: Icon-first design, no reading required to understand screen state
- **Real-time sync**: Events must appear on partner's device via ActionCable/Turbo Streams

## Key Files

- `ARCHITECTURE.md` — Data model, multi-tenancy pattern, UX/UI guidelines
- `PRD.md` — Product requirements and user stories
- `TODO.md` — Phased development roadmap with task IDs (p1-1, p1-2, etc.)
- `config/deploy.yml` — Kamal deployment config
