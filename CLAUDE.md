# CLAUDE.md — NPS Clone

This file provides guidance for AI assistants working on this codebase.

## Project Overview

**NPS Clone** is a Ruby on Rails 8.1 employee recognition web application. It allows authenticated employees to send "Cheers" (short peer-recognition messages) to one another. Admins have access to survey-related features. The name suggests it's modeled after an internal NPS (Net Promoter Score) or engagement tool.

## Tech Stack

| Layer | Technology |
|---|---|
| Language | Ruby 3.3.10 |
| Framework | Rails 8.1.1 |
| Database | SQLite3 (separate DBs per env) |
| Auth | Devise 4.9 |
| Assets | Propshaft |
| JavaScript | Importmap (ESM, no bundler) |
| Frontend | Hotwire (Turbo + Stimulus) |
| Web server | Puma + Thruster |
| Background jobs | Solid Queue |
| Caching | Solid Cache |
| WebSockets | Solid Cable |
| Deployment | Kamal + Docker |
| Testing | Minitest (built-in Rails) + Capybara + Selenium |
| Linting | RuboCop (rubocop-rails-omakase style) |
| Security scanning | Brakeman, bundler-audit, importmap audit |

## Directory Structure

```
nps_clone/
├── app/
│   ├── assets/
│   │   ├── images/
│   │   ├── stylesheets/
│   │   └── application.css
│   ├── controllers/
│   │   ├── application_controller.rb   # Base controller; authenticate_admin! helper
│   │   ├── cheers_controller.rb        # Cheers CRUD (index, new, create)
│   │   └── surveys_controller.rb       # Admin-only surveys (stub)
│   ├── javascript/
│   │   └── application.js              # Importmap entrypoint
│   ├── models/
│   │   ├── application_record.rb
│   │   ├── cheer.rb                    # Core recognition model
│   │   └── user.rb                     # Devise user with role enum
│   └── views/
│       ├── cheers/                     # index, new, create templates
│       └── layouts/
│           └── application.html.erb    # Root layout (PWA-ready)
├── config/
│   ├── application.rb
│   ├── bundler-audit.yml               # CVE ignore list
│   ├── ci.rb                           # Local CI step definitions
│   ├── database.yml                    # SQLite config per environment
│   ├── importmap.rb                    # JS pin definitions
│   └── routes.rb                       # Application routes
├── db/
│   ├── migrate/                        # Ordered migrations
│   ├── schema.rb                       # Current schema (auto-generated)
│   └── seeds.rb
├── test/
│   ├── controllers/
│   │   └── cheers_controller_test.rb
│   ├── fixtures/
│   │   ├── cheers.yml
│   │   └── users.yml
│   ├── models/
│   │   ├── cheer_test.rb
│   │   └── user_test.rb
│   ├── system/                         # Capybara system tests
│   └── test_helper.rb
├── .github/
│   └── workflows/
│       └── ci.yml                      # GitHub Actions CI pipeline
├── Dockerfile                          # Production multi-stage Docker build
└── Gemfile
```

## Data Models

### User (`app/models/user.rb`)
- Devise modules: `database_authenticatable`, `registerable`, `recoverable`, `rememberable`, `validatable`
- Role enum: `employee` (0, default) and `admin` (1)
- `has_many :sent_cheers` — Cheers where `sender_id` = user
- `has_many :received_cheers` — Cheers where `recipient_id` = user
- Default role is set to `employee` on initialization via `after_initialize`

### Cheer (`app/models/cheer.rb`)
- `belongs_to :sender` (User, via `sender_id`)
- `belongs_to :recipient` (User, via `recipient_id`)
- `content` — required text, max 140 characters
- Custom validation: `sender_is_not_recipient` (a user cannot cheer themselves)

### Database Schema
```
users:  id, email, encrypted_password, reset_password_token, remember_created_at, role (int), created_at, updated_at
cheers: id, content (text), sender_id (int), recipient_id (int), created_at, updated_at
```

## Routes

```ruby
resources :cheers, only: [:index, :new, :create]
devise_for :users
get "up" => "rails/health#show"   # health check
```

## Controllers

### ApplicationController
- `allow_browser versions: :modern` — requires modern browser support
- `authenticate_admin!` helper — redirects non-admins to `root_path` with an alert
- `stale_when_importmap_changes` — cache invalidation for importmap changes

### CheersController
- All actions require `before_action :authenticate_user!`
- `index` — shows current user's received and sent cheers, ordered by `created_at DESC`
- `new` — builds a new Cheer; populates `@recipients` with all other employees (excludes current user and admins)
- `create` — sets `sender` to `current_user`, only permits `:content` and `:recipient_id` via strong params

### SurveysController
- Requires both `authenticate_user!` and `authenticate_admin!`
- Currently a stub with no actions implemented

## Development Workflow

### Setup
```bash
bin/setup              # Full setup (DB create, migrate, seed)
bin/setup --skip-server  # Setup without starting the server
```

### Running the App
```bash
bin/rails server       # Start development server on port 3000
```

### Database
```bash
bin/rails db:migrate         # Run pending migrations
bin/rails db:rollback        # Roll back last migration
bin/rails db:seed            # Seed the database
bin/rails db:test:prepare    # Prepare test database
bin/rails db:seed:replant    # Drop, recreate, and reseed (destructive)
```

Always use migrations to change the schema — **never edit `db/schema.rb` directly**.

### Running Tests
```bash
bin/rails test                  # All unit and integration tests
bin/rails test:system           # System tests (Capybara + Selenium)
bin/rails test test/models/cheer_test.rb  # Single test file
```

### Linting and Security
```bash
bin/rubocop                     # Ruby style linting (rubocop-rails-omakase)
bin/rubocop -a                  # Auto-fix safe offenses
bin/brakeman --no-pager         # Rails security analysis
bin/bundler-audit               # Gem vulnerability audit
bin/importmap audit             # JS dependency vulnerability audit
```

### Local Full CI
```bash
bin/ci    # Runs all CI steps locally (defined in config/ci.rb)
```

## CI/CD Pipeline (GitHub Actions)

Defined in `.github/workflows/ci.yml`. Triggered on all pull requests and pushes to `main`. Jobs run in parallel:

| Job | What it does |
|---|---|
| `scan_ruby` | Brakeman (code security) + bundler-audit (gem CVEs) |
| `scan_js` | `bin/importmap audit` (JS dependency CVEs) |
| `lint` | RuboCop with `rubocop-rails-omakase` style guide |
| `test` | `bin/rails db:test:prepare test` |
| `system-test` | `bin/rails db:test:prepare test:system`; uploads screenshots on failure |

**All CI jobs must pass before merging a PR.**

## Key Conventions

### Ruby / Rails Style
- Follow the **rubocop-rails-omakase** style guide (Basecamp's opinionated Rails style)
- Run `bin/rubocop` before committing; CI will fail on violations
- Standard Rails MVC patterns — no custom DSLs or service object layers yet

### Authentication & Authorization
- Use Devise's `authenticate_user!` as a `before_action` on any controller requiring login
- Use `authenticate_admin!` (defined in `ApplicationController`) for admin-only actions
- Always check `current_user` rather than passing user IDs through params; set `sender` server-side

### Strong Parameters
- Only permit parameters that users should control. The `sender` must **never** be a permitted param — always set it from `current_user` in the controller.

### Testing
- Use **fixtures** (not FactoryBot) in `test/fixtures/`
- Include `Devise::Test::IntegrationHelpers` in integration/controller tests and call `sign_in users(:one)` to authenticate
- Test file naming: `test/controllers/cheers_controller_test.rb` mirrors `app/controllers/cheers_controller.rb`
- Fixture passwords use `Devise::Encryptor.digest(User, 'password123')`

### Migrations
- Each migration has a timestamped filename: `YYYYMMDDHHMMSS_description.rb`
- Always run `bin/rails db:migrate` after pulling changes that include new migrations

### JavaScript
- No Node.js / npm / webpack. JavaScript is managed via **Importmap** (`config/importmap.rb`)
- Add JS packages with `bin/importmap pin <package>`
- Avoid inline JavaScript in views; use **Stimulus controllers** in `app/javascript/`

### Views
- ERB templates; use partials for reusable UI
- Layout: `app/views/layouts/application.html.erb` (single layout for all pages)
- PWA manifest and service worker routes exist but are currently commented out

### Docker / Deployment
- Production Docker image uses Ruby 3.3.10-slim with a multi-stage build
- Deployed via **Kamal** (`config/deploy.yml`)
- Runs as non-root user (`rails`, uid 1000) for security
- Thruster handles HTTP asset caching and compression in front of Puma

## Security Notes

- `RAILS_MASTER_KEY` must be set in production (stored in `config/master.key`, gitignored)
- CVEs that are not applicable can be added to `config/bundler-audit.yml` ignore list
- Brakeman runs on every CI build; `--exit-on-warn` is used locally via `bin/ci`
- `allow_browser versions: :modern` prevents requests from outdated browsers

## Current State & Known Gaps

- **Views are stubs**: `cheers/index`, `cheers/new`, and `cheers/create` contain only generated placeholder text — the actual UI is not yet implemented
- **Surveys feature is incomplete**: `SurveysController` has authorization guards but no actions or views
- **No root route defined**: `config/routes.rb` has the root route commented out
- **Model tests are empty**: `CheerTest` and `UserTest` exist but have no test cases yet
- **Cheer fixtures have invalid data**: Both fixture entries have `sender_id: 1` and `recipient_id: 1` (same user), which would fail the `sender_is_not_recipient` validation in real usage
