# CLAUDE.md — TableTopics Desktop

## Key Documents
- **`../docs/ADR.md`** — Architecture Decision Records. Read before structural changes. Append new decisions.
- **Phase 1 plan:** `~/.openclaw/workspace/memory/projects/TableTopics-desktop-phase1.md`

## Build & Dev Commands
```bash
pnpm dev          # Vite dev server (port 1420) — UI only, no Tauri shell
pnpm tauri dev    # Full Tauri dev build (requires Rust)
pnpm build        # Vite production build
pnpm tauri build  # Full Tauri production build (macOS DMG / Windows NSIS)
```

## Architecture
- **Shell:** Tauri 2.x (Rust)
- **Frontend:** React 19 + TypeScript + Vite
- **Styling:** Tailwind CSS v4
- **State:** Zustand (client state) + TanStack Query (server state)
- **Rich text:** TipTap
- **Backend:** B2BPlatform REST API (set `VITE_API_URL` env var)

## Layout
Three-column: LeadList (left, 288px) | LeadProfile + ProposalComposer (center, flex) | AICopilot (right, 320px)

## Key Configuration
- API base URL: `VITE_API_URL` (default: `http://localhost:8080`)
- Auth token: stored in `localStorage` as `auth_token`
- `src/services/api.ts` — all API calls go through here

## Testing
- Run `test-coverage` after major changes
- Unit tests: `pnpm test`
- Component tests in `src/**/*.test.tsx`

## Beads
- Use `bd` from `~/Projects/TableTopics/desktop/` directory
- All tasks tracked in beads — no markdown TODOs
