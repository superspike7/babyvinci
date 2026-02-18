# Vinci - Architecture

## Stack

- **Framework**: Ruby on Rails 8
- **Database**: PostgreSQL
- **Real-time**: ActionCable + Turbo Streams
- **Styling**: TailwindCSS
- **Deployment**: Kamal to Hetzner

## Multi-Tenancy

Simple family-based scoping. No gem needed.

```ruby
# Models
class User < ApplicationRecord
  belongs_to :family
end

class Baby < ApplicationRecord
  belongs_to :family
end

class Activity < ApplicationRecord
  belongs_to :family
  belongs_to :baby
end

# ApplicationController
class ApplicationController < ActionController::Base
  helper_method :current_family

  def current_family
    current_user.family
  end
end

# Scope queries
Baby.where(family: current_family)
Activity.where(family: current_family).order(created_at: :desc)
```

All queries scoped to `current_user.family`. With only 2 users per family, manual scoping is safer and simpler than gem overhead.

## Data Model

```
Family
├── Users (parents)
│   └── belongs_to :family
└── Babies
    └── belongs_to :family

Activity (Delegated Types)
├── Feeding (breast sides, duration, bottle volume)
├── Diaper (wet/dirty, color)
├── Sleep (start_time, end_time)
├── Pumping (duration, left_yield, right_yield)
└── Health (medication, dosage, temperature)
```

## UX/UI Guidelines

### Night Mode
- Background: dark grey (#121212), not pure black
- Text: off-white (#E0E0E0), not pure white
- No blue light emission
- No pure black/white combinations

### One-Handed Operation
- All primary actions in bottom third (thumb zone)
- Bottom navigation bar
- Large tap targets (minimum 48px)
- Floating Action Button for quick logging

### "One Thumb, One Eyeball" Test
- Parent should understand screen state with single glance
- Complete any task in <10 seconds
- No reading required - icon-first design
