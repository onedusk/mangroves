# Admin Interface Requirements

## Audit Log Viewer

### Overview
Administrative interface for viewing and filtering audit events for security and compliance.

### Requirements

#### Audit Event Viewer
- View all audit events for current account
- Filter by:
  - User (dropdown or autocomplete)
  - Action type (account.switch, workspace.switch, etc.)
  - Date range (from/to date pickers)
  - Resource type (Account, Workspace, Team, User)
- Export to CSV for compliance reporting
- Search by metadata fields
- Display columns:
  - Timestamp (with timezone)
  - User (with link to profile)
  - Action (human-readable description)
  - Resource (polymorphic link)
  - IP address
  - Metadata (expandable JSON viewer)

#### PaperTrail Version History
- View model change history on detail pages
- Show who made changes and when
- Diff view showing before/after values
- Revert to previous version (owner only, with confirmation)
- Link from model detail pages to version history

### Implementation Notes

**Query Pattern**:
```ruby
@events = AuditEvent.for_account(Current.account)
                    .recent
                    .includes(:user, :auditable)
                    .page(params[:page])
```

**Access Control**:
- Require admin or owner role
- Scope to Current.account only
- Log access to audit logs (meta-auditing)

**Performance Considerations**:
- Use pagination (50-100 events per page)
- Add database partitioning for large datasets (>1M rows)
- Consider archiving old events (>2 years) to separate table
- Use materialized views for common aggregations

**Export Format** (CSV):
- Headers: Timestamp, User, Action, Resource Type, Resource ID, Metadata
- UTF-8 encoding
- ISO 8601 timestamps
- Escaped metadata JSON

### Future Enhancements
- Real-time event streaming (ActionCable)
- Anomaly detection (unusual access patterns)
- Compliance reports (SOC 2, GDPR)
- Retention policies with automatic archival
