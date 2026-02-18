# Vinci - Product Requirements Document

**Version**: 0.1  
**Last Updated**: 2026-02-18  
**Status**: Pre-launch (Baby due: March 2026)

---

## 1. Problem Statement

New parents in the first year face extreme sleep deprivation and cognitive impairment ("postpartum brain fog"). The critical failure point is the **shift handoff** - when one parent takes over from the other. Without accurate, instant data transfer, parents either:
- Wake the sleeping partner to ask for info (destroying the purpose of shift work)
- Make educated guesses (potentially harmful - overfeeding, missing medications)

**Goal**: Eliminate information asymmetry between co-parents during shift handoffs.

---

## 2. Product Name

**Vinci** - Named after the baby. Simple, memorable, personal.

---

## 3. Core User Stories

| Priority | Story |
|----------|-------|
| P0 | As a parent, I can log a feeding/diaper/sleep event with one thumb in <10 seconds |
| P0 | As a parent, I see new events appear instantly on my partner's device without refreshing |
| P0 | As a parent, I can view a unified chronological timeline of all events |
| P0 | As a parent, I can use the app in complete darkness without blinding myself |
| P1 | As a parent, I can see which breast was used last for breastfeeding |
| P1 | As a parent, I can track pumping sessions and yields |
| P1 | As a parent, I can log medications and temperature |
| P2 | As a parent, I can view a daily/weekly summary (total sleep, total feeding) |

---

## 4. Technical Architecture

### Stack
- **Framework**: Ruby on Rails 8
- **Database**: PostgreSQL
- **Real-time**: ActionCable + Turbo Streams (Rails 8 native - no Redis)
- **Styling**: TailwindCSS
- **Deployment**: Local for dev, Kamal to Hetzner (future)

### Data Model

```
Family (tenant)
├── Users (parents)
│   └── belongs_to :family
└── Babies
    └── belongs_to :family

Activity (Delegated Types - unified timeline)
├── Feeding (breast sides, duration, bottle volume)
├── Diaper (wet/dirty, color)
├── Sleep (start_time, end_time, quality)
├── Pumping (duration, left_yield, right_yield)
└── Health (medication, dosage, temperature)
```

### Security
- **Multi-tenancy**: ActsAsTenant - all queries scoped to family
- No user can ever see another family's data
- WebSocket origins strictly limited to authenticated family

---

## 5. UX/UI Requirements

### Night Mode (Critical)
- Background: `#121212` (dark grey, not pure black)
- Text: `#E0E0E0` (off-white, not pure white)
- No blue light emission
- No pure black/white combinations

### One-Handed Operation
- All primary actions in bottom third (thumb zone)
- Bottom navigation bar (no top hamburger menus)
- Large tap targets (minimum 48px)
- Swipe gestures where possible
- Floating Action Button for quick logging

### "One Thumb, One Eyeball" Test
- Parent should understand screen state with single glance
- Complete any task in <10 seconds
- No reading required - icon-first design

---

## 6. Screen Map

1. **Login/Setup** - Create family, add baby, invite partner
2. **Dashboard** - Unified chronological timeline (main view)
3. **Quick Log** - FAB opens modal to log event type
4. **Baby Profile** - Baby details, birth date, name
5. **Settings** - Account, family management, theme toggle

---

## 7. MVP Feature List

### Phase 1 (v0.1 - "Can we survive tonight?")
- [ ] Family setup (2 parents, 1 baby)
- [ ] Feeding log: breast (L/R side, duration) + bottle (volume)
- [ ] Diaper log: wet/dirty/both, color picker
- [ ] Sleep log: start/stop timer
- [ ] Unified timeline (all events, sorted by time)
- [ ] Real-time sync via ActionCable
- [ ] Dark mode UI
- [ ] One-handed logging

### Phase 2 (v0.2 - "Make it sustainable")
- [ ] Pumping tracking
- [ ] Health/medications logging
- [ ] Daily summary stats
- [ ] Timer controls (pause, resume)

---

## 8. Success Metrics

- **Time to log event**: <10 seconds
- **Sync latency**: <1 second (real-time)
- **Uptime**: 99.9% (parents will panic if app is down at 3am)
- **Dark mode**: No parent reports being blinded

---

## 9. Out of Scope for MVP

- Multiple babies (can add later)
- Nannies/grandparents (multi-family access)
- Analytics dashboards
- Export to PDF/pediatrician reports
- White-labeling
