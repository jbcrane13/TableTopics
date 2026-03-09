# AGENTS.md — LeadForge

This folder is home. Treat it that way.

## Every Session

1. **Read this file** — understand the project structure
2. **Check `docs/`** — architecture decisions and integration docs
3. **B2BPlatform is the core** — LeadForge uses B2BCore and B2BUI from `~/Projects/B2BPlatform`
4. **Mock data by default** — `useMockData = true` in LeadsViewModel for demos

## Project Context

- **What:** iOS app for B2B sales lead management, built on B2BPlatform
- **Why:** Table Topics (hospitality construction leads) demo and client projects
- **Platforms:** iOS 18+ (Swift 6.0)
- **Stack:** SwiftUI + B2BCore (models) + B2BUI (views)

## Structure

```
LeadForge/
├── backend/              # FastAPI + Agent Swarm (optional, for real data)
│   ├── leadforge/       # Python agents
│   └── main.py          # FastAPI entry point
├── ios/
│   └── LeadForge/
│       ├── Package.swift          # SPM, depends on B2BPlatform
│       └── LeadForge/
│           ├── Models/
│           │   └── MockData.swift # Sample leads for demos
│           ├── Views/
│           │   ├── ContentView.swift      # TabView (Leads, Search)
│           │   ├── LeadListView.swift     # Filterable lead list
│           │   ├── LeadDetailView.swift   # Full lead details
│           │   └── LeadSearchView.swift   # Search form
│           ├── ViewModels/
│           │   └── LeadsViewModel.swift   # Observable state
│           └── Services/
│               └── APIService.swift       # Backend API (when not using mock)
└── docs/                 # Architecture docs
```

## Demo Mode

**Default:** App uses mock data (no backend required)

```swift
// In LeadsViewModel
var useMockData = true  // Set to false to use real API
```

**Mock data includes:**
- 5 sample leads across 4 tiers (hot, warm, cool, cold)
- Full company details, decision makers, scores
- Contact info with phone/email

**To use real API:**
1. Start backend: `cd backend && uvicorn main:app --reload`
2. Set `useMockData = false` in LeadsViewModel
3. Or set environment variable `API_BASE_URL=http://localhost:8000`

## Build & Run

```bash
# Generate Xcode project (if project.yml changed)
cd ~/Projects/LeadForge/ios && xcodegen generate

# Build for iOS Simulator
xcodebuild -project LeadForge.xcodeproj -scheme LeadForge -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build

# Or open in Xcode
open LeadForge.xcodeproj
```

**Note:** This project uses XcodeGen. The `.xcodeproj` is generated from `project.yml` and should not be edited directly.

## Key Files

| File | Purpose |
|------|---------|
| `ios/Package.swift` | SPM manifest, links B2BPlatform |
| `LeadForge/LeadForge/Models/MockData.swift` | Sample leads for demos |
| `LeadForge/LeadForge/ViewModels/LeadsViewModel.swift` | State management |
| `LeadForge/LeadForge/Views/LeadListView.swift` | Main list with tier filters |
| `LeadForge/LeadForge/Views/LeadDetailView.swift` | Full lead details |
| `backend/main.py` | FastAPI entry (optional) |

## Backend (Optional)

The backend provides real permit data from Shovels API:

```bash
cd backend
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Create .env with API keys
echo "SHOVELS_API_KEY=your-key" > .env

uvicorn main:app --reload
```

API endpoints:
- `GET /api/leads` — List leads
- `POST /api/leads/search` — Search by city + project types
- `GET /api/leads/{id}` — Get single lead

## Dependencies

- **B2BPlatform** (`~/Projects/B2BPlatform`) — Core models and UI components
  - `B2BCore`: Lead, Company, Project, DecisionMaker, LeadScore
  - `B2BUI`: ScoreIndicator, StatusBadge, DashboardCard

## Integration Pattern

LeadForge is the first consumer of B2BPlatform. The pattern:

```swift
import B2BCore  // Models (no dependencies)
import B2BUI    // SwiftUI views (depends on B2BCore)

// Use models directly
let lead = Lead(company: company, project: project)

// Use views directly
ScoreIndicator(score: lead.score, showBreakdown: true)
```

For new client projects, copy this pattern — see `~/Projects/B2BPlatform/docs/INTEGRATION.md`.

## Architecture Decisions

See `docs/ADR.md` for architecture decision records.

## License

MIT

---

*Updated: 2026-03-07*