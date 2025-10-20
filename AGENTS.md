# Repository Guidelines

## Project Structure & Module Organization
This Rails 8 app keeps domain code under `app/` (controllers, models, services, jobs, components) with deeper guidance in `docs/rails_conventions.txt`. Shared helpers belong in `lib/`, configuration in `config/`, migrations in `db/`, and documentation in `docs/`. Specs live by type inside `spec/`, while compiled assets ship from `app/assets` and `public/`. Treat `tmp/` as ephemeral and leave it untracked.

## Build, Test, and Development Commands
Run `bin/setup` to install gems, prepare databases, and wire up Overcommit hooks (`--reset` rebuilds from scratch). Start the development stack with `bin/dev`, which boots the Rails server plus front-end watchers. Execute the combined lint and test suite with `bin/rake`; add `-m` for parallelism. Target suites individually via `bin/rspec`, `bin/rubocop`, `bin/erblint`, `bin/brakeman`, and `bin/bundle-audit`. Before pushing, rerun the command that exercises your change surface to keep CI clean.

## Coding Style & Naming Conventions
Follow `.editorconfig`: UTF-8, LF endings, two-space indentation (tabs only in `Makefile`). RuboCop (configured by `.rubocop.yml`) enforces Ruby layout and style, so keep controllers slim and push business logic into services or POROs. ERB templates are linted by `.erb_lint.yml`, and JavaScript/TypeScript files should be formatted with Prettier (`.prettierrc.cjs`). Use descriptive snake_case names that mirror directories (`orders/create_service_spec.rb`, `order_presenter.rb`) to make intent obvious.

## Testing Guidelines
Author RSpec examples alongside the code they cover: models in `spec/models`, services in `spec/services`, system/feature flows under `spec/system` or `spec/features`. Use factories, prefer minimal data, and rely on `let` helpers over instance variables. When shipping new behavior, write the spec first, confirm it fails, and verify it passes with `bin/rspec` or `bin/rake` once implemented. Note any required seeds or background jobs in the spec description when they affect execution.

## Commit & Pull Request Guidelines
Compose commits around a single concern with a short imperative subject (“Add order cancellation service”). Include test or lint command outputs in the PR description, link tracking issues, and attach UI screenshots when relevant. Install Overcommit hooks (`overcommit --install`) so RuboCop, ERB lint, and schema checks run pre-commit. Rebase feature branches frequently to keep migrations and schema files aligned before requesting review.

## Security & Configuration Notes
Store secrets in environment variables and mirror required keys in `.env.sample`. Kamal deployment manifests live in `.kamal/`; update them alongside infra changes. When adjusting queues or scheduled jobs, highlight the operational impact in your PR so maintainers can update Solid Queue or Cron during deployment.
