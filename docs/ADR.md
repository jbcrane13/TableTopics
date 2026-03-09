# Architecture Decision Records

This file records significant architectural decisions for LeadForge.

## ADR-001: SPM with Local Package Dependency

**Date:** 2026-03-06

**Status:** Accepted

**Context:**
LeadForge needs to share code with other client apps and potentially other products. We need a dependency management strategy that supports:
- Local development with immediate feedback
- Future distribution to other projects
- Swift 6 strict concurrency

**Decision:**
Use Swift Package Manager with a local package dependency on B2BPlatform.

```
Package.swift:
  dependencies: [
    .package(path: "../../B2BPlatform")
  ]
```

**Rationale:**
- Zero-config local development (changes in B2BPlatform visible immediately)
- Swift 6 strict concurrency enforcement automatic
- Single source of truth for models (B2BCore) and UI (B2BUI)
- Git-native versioning for future releases

**Consequences:**
- Must keep B2BPlatform and LeadForge in sibling directories
- For production, switch to git URL dependency

---

## ADR-002: Mock Data by Default

**Date:** 2026-03-07

**Status:** Accepted

**Context:**
Demoing LeadForge requires showing realistic lead data. The backend requires API keys that may not be available during client demos.

**Decision:**
Default to mock data in `LeadsViewModel.useMockData = true`. The app works without a backend.

**Rationale:**
- Demos work immediately without infrastructure
- No API keys needed for basic functionality
- Realistic sample data shows all features
- Easy to switch to real API when available

**Implementation:**
```swift
// In LeadsViewModel
var useMockData = true  // Set false for real API

// In loadLeads()
if useMockData {
    leads = MockData.sampleLeads
    return
}
```

**Consequences:**
- Must update `MockData.swift` when adding new features
- Backend is optional for basic demos
- Search filters mock data, not real API

---

## ADR-003: TabView with List + Search

**Date:** 2026-03-06

**Status:** Accepted

**Context:**
LeadForge needs a simple navigation pattern for sales reps to browse and find leads.

**Decision:**
Use TabView with two tabs: Leads (browse/filter) and Search (form-based).

**Rationale:**
- Familiar iOS pattern
- Leads tab shows tier-based filtering (Hot/Warm/Cool/Cold)
- Search tab for location + project type queries
- NavigationStack for detail views

**Structure:**
```
TabView
├── Leads (LeadListView)
│   └── LeadDetailView
└── Search (LeadSearchView)
```

---

## ADR-004: B2BUI for Shared Views

**Date:** 2026-03-06

**Status:** Accepted

**Context:**
LeadForge needs consistent UI for lead scoring and status display. These components should be reusable across client apps.

**Decision:**
Implement core UI components in B2BUI (ScoreIndicator, StatusBadge, DashboardCard). LeadForge imports and uses them.

**Rationale:**
- Consistent visual language across client apps
- Score visualization is domain-specific (tier colors, breakdown)
- Status badges have business logic (status colors, labels)
- Single source of truth for UI components

**Consequences:**
- B2BUI changes affect all client apps
- Keep B2BUI generic enough for multiple use cases
- LeadForge can have app-specific views alongside

---

*Last updated: 2026-03-07*