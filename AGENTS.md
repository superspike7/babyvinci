# AGENTS.md - Davinci Crib

## Project Overview

- **Project name**: Vinci
- **Type**: Ruby on Rails 8 web application
- **Purpose**: Early parenting companion app to help new parents get organized, reduce stress, and get guidance for the first year of their first baby
- **Deployment**: Kamal on Hetzner VPS
- **Styling**: TailwindCSS

## Project Context - Read First

- **PRD.md**: Product requirements, feature specifications, and UX guidelines
- **TODO.json** / **TODO.md**: Current task progress - always read these at session start to understand what's done and what's pending

## Build / Lint / Test Commands

### Running Tests

```bash
# Run all tests
rails test

# Run system tests
rails test:system

# Run a single test file
bin/rails test test/models/user_test.rb

# Run a single test (specify line number)
bin/rails test test/models/user_test.rb:5

# Run tests in parallel
rails test:parallel
```

### Linting

```bash
# Run RuboCop
rubocop

# Run RuboCop with auto-fix
rubocop -A

# Run only specific cops or files
rubocop app/models/user.rb
```

### Development

```bash
# Start development server
rails server
# or
rails dev

# Run Rails console
rails console
# or
rails c

# Generate a new migration
rails generate migration AddFieldToModel field_name:datatype

# Run pending migrations
rails db:migrate

# Rollback last migration
rails db:rollback

# Reset database
rails db:reset
# or
rails db:migrate:reset
```

### Asset Building

```bash
# Build assets for development
rails assets:precompile

# Build assets for production
RAILS_ENV=production rails assets:precompile
```

### Deployment (Kamal)

```bash
# Deploy to Hetzner
kamal deploy

# Boot production servers
kamal boot

# Check deployment status
kamal status

# Rollback to previous version
kamal rollback
```

## Code Style Guidelines

### General Principles

- **Always prioritize simplicity** over cleverness
- **Follow Rails conventions** - convention over configuration
- **Prefer vanilla Rails** solutions over gems when possible
- **Minimalism** - do the simplest thing that could possibly work

### References

Read and apply principles from:
- https://dev.37signals.com/a-vanilla-rails-stack-is-plenty/
- https://dev.37signals.com/vanilla-rails-is-plenty/
- https://dev.37signals.com/domain-driven-boldness/
- Sandi Metz's POODR (Practical Object-Oriented Design in Ruby)

### Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Models | Singular, CamelCase | `Baby`, `Parent` |
| Controllers | Plural, CamelCase | `BabiesController` |
| Views | Plural, snake_case | `babies/show.html.erb` |
| Tables | Plural, snake_case | `babies`, `parents` |
| Variables | snake_case | `baby_name`, `parent_id` |
| Methods | snake_case | `full_name`, `calculate_age` |
| Constants | SCREAMING_SNAKE_CASE | `MAX_HEIGHT` |
| DB Columns | snake_case | `created_at`, `parent_id` |

### File Organization

```
app/
├── controllers/
│   └── application_controller.rb    # Base controller
├── models/
│   └── application_record.rb         # Base model
├── views/
│   ├── layouts/
│   │   └── application.html.erb
│   └── {controller}/
│       └── {action}.html.erb
├── helpers/
│   └── application_helper.rb
├── jobs/
│   └── application_job.rb
├── mailers/
│   └── application_mailer.rb
└── channels/
    └── application_cable/
```

### Controllers

- Use strong parameters
- Restrict actions to 7 or fewer
- Avoid before_actions when possible; use callbacks judiciously
- Return meaningful HTTP status codes
- Use resourceful routing
- Controllers access domain models directly - call methods on models rather than using service objects

```ruby
# Good
class BabiesController < ApplicationController
  def index
    @babies = Baby.all
  end

  def show
    @baby = Baby.find(params[:id])
  end

  def create
    @baby = Baby.new(baby_params)
    if @baby.save
      redirect_to @baby, notice: "Baby was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def baby_params
    params.require(:baby).permit(:name, :birth_date, :parent_id)
  end
end
```

### Models

- Keep models focused on single responsibility
- Use concerns for shared behavior
- Use scopes for reusable query fragments
- Validate presence and format, not unnecessary constraints
- Build rich domain models - expose a natural API from domain models

```ruby
# Good
class Baby < ApplicationRecord
  belongs_to :parent
  has_many :milestones

  validates :name, :birth_date, presence: true

  scope :by_parent, ->(parent) { where(parent:) }

  def age_in_days
    (Date.current - birth_date).to_i
  end
end
```

### Rich Domain Models

Build rich domain models that expose a natural API. Use concerns to organize code and delegate to POROs when complexity justifies it.

```ruby
# Using concerns for organization
class Baby < ApplicationRecord
  include Ageable
  include MilestoneTracker
end

module Baby::Ageable
  def age_in_days
    (Date.current - birth_date).to_i
  end
end
```

- Controllers call methods directly on models: `@baby.age_in_days`
- No service objects or interactors needed
- Don't separate application and domain layers

### Views

- Use partials for repeated markup
- Use helpers for formatting and logic
- Avoid complex logic in views
- Use Turbo/Stimulus for interactivity (Rails 8 default)
- TailwindCSS for styling

```erb
<!-- Good -->
<%= render "shared/flash_messages" %>

<%= form_with model: @baby do |form| %>
  <div class="field">
    <%= form.label :name %>
    <%= form.text_field :name, class: "rounded border-gray-300" %>
  </div>
<% end %>
```

### Database

- Use migrations for schema changes
- Add appropriate indexes for query performance
- Use PostgreSQL for production
- Prefer simple column types (string, text, integer, datetime, boolean)
- Use references for associations

```ruby
# Good
class CreateBabies < ActiveRecord::Migration[8.0]
  def change
    create_table :babies do |t|
      t.string :name, null: false
      t.date :birth_date, null: false
      t.references :parent, null: false, foreign_key: true

      t.timestamps
    end

    add_index :babies, :birth_date
  end
end
```

### Error Handling

- Use rescue_from for controller-level exception handling
- Return appropriate HTTP status codes
- Show user-friendly error messages
- Log errors for debugging

```ruby
class ApplicationController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  private

  def record_not_found
    render file: "public/404.html", status: :not_found
  end
end
```

### JavaScript

- Use Turbo for page transitions
- Use Stimulus for interactivity
- Keep JavaScript minimal
- Use TailwindCSS for all styling

### CSS

- Use TailwindCSS utility classes
- Avoid custom CSS unless absolutely necessary
- Keep styles inline with components when possible

### Testing

- Write system tests for user flows
- Write unit tests for models
- Use fixtures or factories sparingly
- Test behavior, not implementation

```ruby
# Good
require "system/test_case"

class BabyTest < SystemTestCase
  def test_creates_new_baby
    visit new_baby_path
    fill_in "Name", with: "Emma"
    select_date 1.week.ago, from: "birth_date"
    click_button "Create Baby"

    assert_text "Baby was successfully created"
  end
end
```

### Git

- Use feature branches
- Write concise commit messages
- Rebase over merge when appropriate

### Environment Variables

- Use `.env` for local development
- Never commit secrets
- Use `ENV.fetch("VARIABLE")` to require variables in production

```ruby
# Good
DATABASE_URL = ENV.fetch("DATABASE_URL")
SECRET_KEY_BASE = ENV.fetch("SECRET_KEY_BASE")
```

### Gems

Keep dependencies minimal. Only add gems when:
- Use Rails Default gems
- It solves a problem that vanilla Rails cannot
- The gem is well-maintained
- The benefit significantly outweighs the complexity

### Queries

- Use `where` with conditions, not Ruby iteration
- Use `joins` for associations
- Use `includes` to avoid N+1 queries
- Use `select` to fetch only needed columns
- Add database indexes for frequently queried columns

```ruby
# Good - avoids N+1
@babies = Baby.includes(:parent).where(parent: { active: true })

# Good - specific columns
Baby.pluck(:name, :birth_date)
```

### Forms

- Use `form_with` for all forms
- Use nested attributes for associations
- Use model-backed forms over manual form tags

### Routes

- Use resourceful routing
- Use scope/namespace for grouping
- Keep routes simple

```ruby
# config/routes.rb
Rails.application.routes.draw do
  resources :babies do
    resources :milestones
  end

  resource :session
  resource :profile
end
```

## Cursor / Copilot Rules

None currently configured.

## Deployment Notes

- Uses Kamal for deployment to Hetzner VPS
- Ensure `Kamal_ALT_SIGNAL` is not set during deploys to avoid signal issues
- Review Kamal configuration for Hetzner-specific settings
