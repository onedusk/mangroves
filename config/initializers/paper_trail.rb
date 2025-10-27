# frozen_string_literal: true

PaperTrail.config.enabled = true
PaperTrail.config.has_paper_trail_defaults = {
  on: %i[create update destroy]
}

# Use JSON serializer for jsonb columns
PaperTrail.serializer = PaperTrail::Serializers::JSON

# NOTE: PaperTrail::Version is exempt from TenantScoped because it's a gem-managed
# model with its own scoping requirements. We filter versions by account_id at the
# query level when needed.
