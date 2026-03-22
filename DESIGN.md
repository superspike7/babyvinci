---
title: BabyVinci Design System
status: active
canonical: true
source_of_truth: DESIGN.md
selected_direction: "Prototype 02 - Clinical Calm"
last_updated: 2026-03-23
---

# DESIGN.md — BabyVinci UI Direction

## Status
Active canonical visual and UX design reference.

## Decision
- Selected direction: Prototype 02 - Clinical Calm
- Intent: calm, serious, information-led mobile UI for exhausted co-parents
- Use this file for visual decisions; use `PRD.md` for product scope and behavior

## Product Feel
- serious family tool
- calm, not cold
- trustworthy, not clinical theater
- efficient at 3 AM without looking harsh
- designed for shared handoff clarity, not engagement metrics

## Design Principles
- information first
- fast scan beats decoration
- one primary read per screen
- mobile-first, one-hand friendly
- warmth comes from restraint, not cuteness

## UI Copy Rules

### Priority
- treat these copy rules as a high-priority design reference for every user-facing screen
- apply them before inventing new labels, helper text, empty states, or status messages

### Write for the parent, not the builders
- use product-facing language only
- never expose roadmap or implementation language in the UI
- forbidden in interface copy: `Phase`, `MVP`, `task`, `milestone`, ticket ids, or internal project shorthand

### Copy qualities
- calm, short, clear, practical
- written for a tired parent using the app at 3 AM
- state what is happening, what matters now, or what to do next
- prefer plain words over clever phrasing or startup marketing language

### Good defaults
- favor state/action copy like `Sign in`, `Create account`, `Shared log`, `Next up`
- prefer direct reassurance through clarity, not cheerleading
- if a sentence can be shorter without losing meaning, shorten it

### Final check before shipping
- would a sleep-deprived parent understand this instantly?
- does this sound like product copy rather than team/planning language?
- is this the shortest clear version?

## Chosen Direction

### Why this direction won
- strongest scan speed of the three concepts
- easiest to scale into Phase 1 and later doctor-summary views
- calm enough for home use, structured enough to feel trustworthy
- distinctive without drifting into trendy startup UI

### Emotional target
- exhale
- confidence
- quiet focus

### Anti-target
- toy baby app
- hospital portal
- generic SaaS dashboard
- sentimental nursery branding

## Visual System

### Source hierarchy
- `DESIGN.md` is the canonical visual source of truth
- `PRD.md` defines product purpose, scope, behavior, and acceptance criteria
- when a screen-specific choice is unclear, reuse an existing canonical screen pattern before inventing a new one
- if no pattern exists, update `DESIGN.md` with the new rule after the design is chosen

### Color
- Canvas: soft blue-green neutral, light and quiet
- Surfaces: white or near-white only when separation is needed
- Primary accent: deep teal for key summary emphasis
- Support accent: muted sea-glass teal for secondary surfaces and chips
- Urgent red: reserved for urgent concern outcomes only
- Caution amber: sparing use for caution states only

### Reference palette
- Canvas: `#EEF5F4` -> `bg-vinci-canvas`
- Elevated surface: `#F7FBFB` -> `bg-vinci-surface`
- Base surface: `#FFFFFF` -> `bg-vinci-base`
- Ink: `#102126` -> `text-vinci-ink`
- Secondary text: `#4F6B71` -> `text-vinci-text`
- Quiet label: `#66858B` -> `text-vinci-label`
- Primary accent: `#10343C` -> `bg-vinci-accent` / `text-vinci-accent`
- Accent tint: `#DCEBEA` -> `bg-vinci-accent-tint`
- Border: `#D7E5E6` -> `border-vinci-border`
- Urgent: `#B9382F` -> `bg-vinci-urgent` / `text-vinci-urgent`
- Caution: `#A56A1F` -> `bg-vinci-caution` / `text-vinci-caution`

### Tailwind theme tokens
- canonical BabyVinci colors live in `app/assets/tailwind/application.css`
- use semantic classes like `bg-vinci-canvas`, `text-vinci-ink`, and `border-vinci-border`
- avoid reintroducing raw hex values in views once implementation starts

### Typography
- Headings: geometric sans with strong numerals and compact width
- Body: neutral sans with high legibility and calm rhythm
- Current preferred pairing: `Sora` for headings, `IBM Plex Sans` for body
- Fallback if self-hosting is not ready: one neutral sans across the UI

### Type rules
- body text: 16px minimum on mobile
- large numbers should carry the hierarchy for time-since states
- labels stay quiet, uppercase only when they improve scan speed
- avoid personality fonts, scripts, or playful rounded faces

### Token table

#### Spacing
- `space-1`: 4px - only inside dense internal pairs
- `space-2`: 8px - micro spacing between label and value
- `space-3`: 12px - compact vertical rhythm in rows
- `space-4`: 16px - default mobile gap
- `space-5`: 20px - section interior spacing
- `space-6`: 24px - default card padding
- `space-8`: 32px - section separation inside app surfaces
- `space-10`: 40px - page section separation

#### Radius
- `radius-sm`: 16px - chips and small controls
- `radius-md`: 20px - tiles and grouped cards
- `radius-lg`: 26px - emphasis blocks
- `radius-xl`: 32px - main mobile app shell

#### Border and shadow
- default border: `1px solid #D7E5E6`
- quiet divider: `#D7E5E6`
- shell shadow: `0 22px 70px rgba(17, 63, 72, 0.10)`
- do not create alternate shadow styles unless a component is truly elevated above the app shell

## Layout Rules
- mobile-first single column
- top summary block first
- two essential status blocks near the top: last feed, last diaper
- one short current-read block that answers "what matters now"
- recent timeline follows immediately after summary
- sticky bottom primary actions on mobile: Feed, Diaper
- use cards only for separation, not as default scaffolding everywhere

### Canonical page frame
- page canvas spans full height with the canvas color
- top intro band uses elevated surface and bottom border
- content area uses two columns on large screens: explainer rail + mobile app surface
- explainer rail max width: 300px
- app surface max width: 430px
- app surface uses `radius-xl`, default border, elevated surface, and shell shadow

### Canonical app screen header
- eyebrow label in quiet text
- screen title in `Sora`
- one contextual chip on the right
- one supporting sentence under the title row
- use this structure for Today, Timeline, forms, and settings-level screens

## Component Guidance

### Component inventory
- app screen header
- context chip
- summary tile
- current-read block
- grouped list section
- timeline row
- field group
- segmented choice row
- sticky action bar

### Summary blocks
- bold number first
- quiet label second
- one line of supporting detail max
- no decorative icons unless they materially speed recognition
- always render as paired or grouped tiles, not isolated floating cards
- use white surface on the default canvas

### Current-read block
- one sentence only
- should reduce uncertainty, not add advice theater
- background may use the deep accent color for hierarchy
- if the screen is a status-first surface like Today, use the deep accent version
- if the screen is a form or log-detail surface, use the white-surface version unless stronger emphasis is required
- optional supporting stat is allowed on the right; never more than one

### Timeline rows
- show: event type, compact detail, author, elapsed time
- optimize for under-2-second scanning
- visual rhythm comes from spacing and dividers, not heavy decoration
- left column should carry either kind or clock, but not both unless the page blueprint explicitly calls for it
- author line always uses secondary text
- elapsed time stays right-aligned when space permits

### Field groups
- use one white grouped surface for each form section
- section starts with quiet uppercase label
- each field has a short label and one clear value area
- avoid helper text unless the field is ambiguous
- optional fields belong in a lower-emphasis section after required fields

### Segmented choice row
- use for feed mode, diaper type, and similarly small mutually exclusive sets
- one selected segment only in the static prototype unless the PRD calls for multi-select
- selected segment uses accent tint and darker ink
- unselected segments stay on white surface with quiet border

### Quick actions
- primary only
- large tap targets
- visually obvious but not louder than current status
- avoid tertiary actions in the sticky bar
- default labels in Phase 1: `Feed`, `Diaper`
- action bar background uses a slightly tinted surface to separate it from content above

### Empty states
- calm and matter-of-fact
- tell the parent the next useful action
- never guilt, never celebrate absence

### Context chips
- chip content should describe state, not marketing
- examples: `Day 47`, `Shared log`, `Now`, `Draft invite`
- use accent tint background, compact uppercase text, and `radius-sm`

## Interaction and Motion
- motion is minimal and mostly instant
- subtle Turbo transitions are fine
- no celebratory animation for logging
- no decorative hover-driven UI patterns as a core dependency

## Copy Style
- calm, short, direct
- support the next decision
- no optimization language
- no judgment language
- no fake certainty in medical-adjacent moments

### Copy formatting rules
- use sentence case for body copy
- use uppercase only for small structural labels and chips
- screen titles should be 1-3 words when possible
- current-read copy should be one sentence, max roughly 70 characters before wrapping on mobile
- avoid exclamation marks in Phase 1 core flows

### Time and naming rules
- elapsed labels: `19 min`, `1 hr 12 min`, `18 min ago`
- absolute times use 24-hour compact format in prototypes unless product chooses otherwise
- event names: `Feed`, `Diaper`, `Sleep`
- detail strings stay compact: `Formula, 80 ml`, `Wet + stool`, `Breast, 14 min`
- author labels always render as `Logged by Name`

## Screen Blueprints

### Today
- header
- two summary tiles: last feed, last diaper
- one accent current-read block with optional stat
- recent timeline section limited to the newest entries
- sticky bottom action bar

### Timeline
- header
- optional white-surface current-read summary
- day-grouped event sections in reverse chronological order
- each day section shows day label plus log count
- sticky bottom action bar

### Feed form
- header with contextual chip like `Now`
- one required section first: timestamp, mode
- optional section second: amount, side, duration
- save area anchored near the bottom
- supporting copy should reinforce speed and clarity, not training or education

### Diaper form
- header with contextual chip like `Now`
- one required section first: timestamp, type
- optional section second: color note
- save area anchored near the bottom

### Invite parent
- header
- one short explanatory paragraph
- one primary field group for email
- one quiet note about shared access and equal permissions
- one primary send action

### More / Settings
- header
- simple grouped rows
- no dashboard-style metrics
- use rows and section dividers, not decorative cards

## Reproduction Checklist
- use the canonical page frame
- use only documented colors, radii, and shadow values
- use `Sora` for titles and numbers that carry hierarchy
- use `IBM Plex Sans` for body, labels, and supporting copy
- choose from the documented screen blueprints before inventing a new layout
- keep one primary read per screen
- if a component is not defined here, add it here before repeating it across screens

## Avoid
- random pastel gradients
- cartoon nursery visuals
- glassmorphism
- oversized decorative illustration
- dense dashboard chrome
- repeated icon-card grids
- purple/blue AI-default palettes
- anything that looks built for investors before parents

## Implementation Notes
- Tailwind is the default styling layer
- prefer reusable tokens/classes once the real app shell is built
- self-host fonts before shipping if custom fonts remain part of the final system
- if a future screen conflicts with this doc, update this doc deliberately rather than drifting ad hoc

## Fresh-Agent Prompt Seed
- Read `PRD.md` for the screen requirements.
- Read `DESIGN.md` and follow its token table, canonical page frame, component inventory, copy rules, and screen blueprint.
- Reuse existing canonical BabyVinci screen patterns before inventing anything new.
- Keep the result mobile-first, quiet, and information-led.
- If a required component is missing from `DESIGN.md`, add the rule after the design decision is made.
