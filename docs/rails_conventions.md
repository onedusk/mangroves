# Rails Conventions — Condensed One‑Pager

A pragmatic “what‑goes‑where” map for a modern Rails app (Hotwire + Solid* + Postgres + RSpec + Docker/Kamal).

---

## Golden Rules

* Keep **ActiveRecord lean**: persistence, validations, simple scopes only.
* **Controllers orchestrate**, business logic lives in **Services**.
* **Views stay dumb**: use **Components**/**Presenters** for formatting/derivations.
* Prefer **idempotent** operations, **transactions** for write‑sets, and **jobs** for slow/remote work.
* Give everything a **single, obvious home** (below).

---

## Where Things Go

* **Controllers** (`app/controllers/*`): parse params → authorize → call service → choose response. ≤ ~20 lines/action; strong params in private methods; render via components/presenters.
* **Models** (`app/models/*`): relations, validations, enums, side-effect-free scopes; DB constraints mirror validations; wrap multi-record writes in transactions. Multi-tenant tables with an `account_id` column must `include TenantScoped`—`spec/tools/tenant_scoping_guard_spec.rb` enforces this.
* **Services** (`app/services/*`): command objects for use cases. Name as `Domain::Action` with `call!` (`Orders::Create.call!(current_user:, params:)`). No rendering/HTTP here.
* **Presenters/Decorators** (`app/presenters/*`): view‑facing formatting; pure, no writes/queries.
* **Components** (`app/components/*` or Phlex): reusable UI; no DB calls; accept hydrated inputs; ship previews.
* **Jobs** (`app/jobs/*`): async IO/emails/imports; idempotent; retries/backoff; delegate heavy work to services.
* **Mailers** (`app/mailers/*`): compose email; templates in `app/views/**/mailer/*`; deliver via jobs (`deliver_later`).
* **Channels** (`app/channels/*`): ActionCable streams; authorize in `subscribed`; broadcast from jobs/services; `stream_for record`.
* **JavaScript** (`app/javascript/*`): Hotwire first (Turbo frames/streams), then small Stimulus controllers (1 behavior/controller; data attrs > selectors).
* **Views** (`app/views/*`): templates only; prefer Turbo Frames/Streams; layouts in `app/views/layouts`.
* **Helpers** (`app/helpers/*`): tiny formatting utilities only (no queries/mutation).

---

## Service Pattern (Command)

* **Naming**: `Feature::Action` (e.g., `Orders::Create`).
* **API**: `.call!(...)` raises typed domain errors; `.call(...)` returns `Result`/`Either` if you prefer.
* **Behavior**: validate inputs → transaction (if writes) → call collaborators → return domain object/id.
* **Idempotency**: accept natural keys or dedup tokens; guard via unique indexes.

**Skeleton**

```ruby
module Orders
  class Create
    Error = Class.new(StandardError)
    def self.call!(current_user:, params:)
      Order.transaction do
        order = current_user.orders.create!(params)
        Payments::Charge.call!(order: order) if order.total_cents.positive?
        order
      end
    rescue ActiveRecord::RecordInvalid => e
      raise Error, e.record.errors.full_messages.to_sentence
    end
  end
end
```

---

## Solid* Gems (Operational Defaults)

* **Solid Queue**: queues = `default`, `mailers`, `low`, `critical`; keep jobs short; use dedup keys; configure retries with exponential backoff.
* **Solid Cache**: `Rails.cache.fetch(key, expires_in: 15.minutes) { compute }`; namespace by model version to avoid stale formats.
* **Solid Cable**: Postgres‑backed; fine for small/medium scale; stream to granular keys.

---

## Testing (RSpec – minimal lanes)

* **Model**: validations/scopes; DB constraint parity.
* **Service**: happy path + failure modes; transactional effects.
* **Request/System**: controller orchestration, Turbo flows, permissions.
* **Job**: enqueuing, idempotency, retry behavior.

---

## Ops & Performance

* **Transactions**: wrap write‑sets; avoid long‑running work inside.
* **Backgrounding**: network/file IO → Jobs; broadcast from jobs/services.
* **Caching**: compute‑heavy/pure → `Rails.cache`; key by inputs + version.
* **N+1**: preload in controllers/services (`includes`, `preload`).
* **Docker/Kamal**: build once; env via credentials; run migrations on deploy hook; healthchecks for web/worker.

---

## Anti‑Patterns (Avoid)

* Fat models/controllers; pushing business rules into callbacks.
* Helpers doing queries/mutation; components hitting the DB.
* Passing raw `params` to models/services.
* Long jobs with complex branching; controller‑initiated broadcasts.

---

## Quick Reference (Do/Don’t)

* **Do**: `Orders::Create.call!(current_user:, params:)` → redirect/render via component.
* **Don’t**: `Order.create_from(params)` with emails/HTTP from the model.
* **Do**: `scope :recent, -> { order(created_at: :desc) }`.
* **Don’t**: scopes with side effects or params.

---

## (Optional) Document Condenser — Greedy Set‑Cover

* Define schema fields `R_t`, must‑keep set `M`, and segment costs `c_i`.
* Iterate: pick segment maximizing `(new_fields*α + new_must*β) / c_i`.
* Stop when all fields/must‑keeps covered; prune redundancies.
* Enforce budget `B` via rule‑based compression or minimal slack ε.
* Assemble output in fixed schema order; verify provenance.

---

## Multi‑Tenant Rails (Insights & Patterns)

### 1) Tenancy Models (choose explicitly)

* **Shared DB, shared schema (tenant_id column)** — simplest; composite indexes; weakest isolation.
* **Shared DB, per‑tenant schemas** — stronger isolation; migrations fan‑out; connection mgmt complexity.
* **Per‑tenant DBs** — strongest isolation; ops heavy; use Rails multi‑db + role switching.
* **Pragmatic default**: shared schema **+ Postgres RLS** to enforce isolation at the DB layer.

### 2) Request → Tenant Resolution

* Identify via **subdomain/path/header/token**. Load `Account`, set thread‑local context with `Current`.
* **Middleware**

```ruby
# config/application.rb
config.middleware.use TenantMiddleware

class TenantMiddleware
  def initialize(app) = (@app = app)
  def call(env)
    req = ActionDispatch::Request.new(env)
    account = Account.lookup!(req) # subdomain/domain/header/api key
    Current.set(tenant: account) { @app.call(env) }
  end
end

class Current < ActiveSupport::CurrentAttributes
  attribute :tenant, :user
end
```

### 3) Data Model & Indexing

* Every tenant‑owned row has `account_id` (or `tenant_id`) **NOT NULL** with FK.
* **Composite uniques** (scope by tenant):

```ruby
add_index :projects, [:account_id, :slug], unique: true
```

* Guard cross‑tenant associations:

```ruby
validate :same_tenant
def same_tenant
  errors.add(:base, "cross‑tenant association") if other&.account_id && other.account_id != account_id
end
```

### 4) Queries & Enforcement

* Avoid `default_scope`. Prefer explicit scopes/services:

```ruby
scope :for_tenant, ->(t) { where(account_id: t.id) }
```

* **Postgres RLS** (recommended for shared schema):

```sql
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
CREATE POLICY tenant_iso ON projects
  USING (account_id = current_setting('app.tenant_id')::uuid);
```

* Set/reset the setting per request/job:

```ruby
around_action ->(c,blk){
  ActiveRecord::Base.connection.execute(["SET app.tenant_id='%s'", Current.tenant.id])
  blk.call
ensure
  ActiveRecord::Base.connection.execute("RESET app.tenant_id")
}
```

### 5) Jobs, Realtime, & External IO

* **Jobs** carry tenant context explicitly and restore it:

```ruby
class ApplicationJob < ActiveJob::Base
  around_perform do |job, block|
    tenant = Account.find(job.arguments.extract_options!.fetch(:tenant_id)) rescue Current.tenant
    Current.set(tenant:) { block.call }
  end
end
```

* **ActionCable** stream keys include tenant: `stream_for [Current.tenant, record]`.
* **S3/Blob paths** prefix with tenant: `accounts/#{account.id}/...`.

### 6) Caching, Sessions, & Rate Limits

* Namespace cache keys: `Rails.cache.fetch([Current.tenant.id, :key]) { ... }` (works with Solid Cache).
* Session domain for subdomain tenancy: wildcard cookie domain with care; for custom domains set per‑tenant host.
* Rate limit per tenant (Rack::Attack): key includes `Current.tenant.id`.

### 7) Billing & Entitlements

* Store `plan` on `Account`; gate features via policy or **Flipper** per tenant.
* Stripe: one customer per account; use billing portal links; record metered usage keyed by tenant.

### 8) Testing & Guardrails

* RSpec helper sets `Current.tenant`; factories always attach `account`.
* Shared examples assert: (a) cross‑tenant queries return 0, (b) unique indexes are tenant‑scoped, (c) jobs set context.
* Add a CI check to **grep for `default_scope`** on tenant models.

### 9) Migrations & Operations

* Data migrations must be **scoped** by tenant; avoid cross‑tenant `UPDATE` without `WHERE account_id = ?`.
* For schema‑per‑tenant, implement migration fan‑out + retries; for many tenants, run in batches.
* Backups/restores: support **per‑tenant export** (logical dump) and whole‑cluster snapshots.

### 10) Observability & SLOs

* Log with `tenant_id` field; propagate to traces/metrics.
* Per‑tenant dashboards for error rate, job latency, DB time; alert on noisy‑neighbor patterns.

### Safe Defaults Checklist

* `belongs_to :account` on all tenant‑owned models.
* All queries go through services using `Current.tenant` **AND/OR** RLS is enabled.
* Composite uniques include `account_id`.
* Cache keys, blobs, Cable streams **prefixed by tenant**.
* Jobs accept `tenant_id` and restore context.
* Webhooks/API requests validated and mapped to a tenant.
