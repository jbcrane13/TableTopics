# LeadForge Architecture

## Agent Swarm Pattern

```
┌─────────────────────────────────────────────────────────┐
│                    AgentOrchestrator                    │
├─────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────┐  ┌────────────────┐  │
│  │ PermitScout  │→│ Enrich   │→│ Qualify         │  │
│  │   (Shovels)  │  │ (Apollo) │  │ (BuildZoom)     │  │
│  └──────────────┘  └──────────┘  └────────────────┘  │
│         │                │               │            │
│         └────────────────┴───────────────┘            │
│                             ↓                          │
│                  ┌────────────────┐                     │
│                  │ Prioritize     │                     │
│                  │ (Scoring)      │                     │
│                  └────────────────┘                     │
│                             ↓                          │
│                      🎯 Hot Leads                       │
└─────────────────────────────────────────────────────────┘
```

## Data Flow

1. Sales rep requests leads (iOS → FastAPI)
2. PermitScout queries Shovels API
3. Enrichment Agent finds decision makers
4. Qualification Agent validates track record
5. Prioritization Agent scores leads
6. Results returned to sales rep

## Scoring Algorithm

```
Lead Score = (
  project_value_estimate * 0.30 +
  contractor_completion_rate * 0.25 +
  decision_maker_found * 0.20 +
  timing_urgency * 0.15 +
  similar_projects_completed * 0.10
)

Hot threshold: score > 0.70 + contact found
```
