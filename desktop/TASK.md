# BUILD TASK: LeadForge Desktop App

You are building the LeadForge desktop app for TableTopics. This is a Tauri 2 + React 19 + TypeScript + Tailwind v4 + Zustand + TanStack Query app.

## Design Reference
Open and study the mockup at ./mockup.html — it is the approved UI design (the "Forge" theme). Use it as the visual reference for EVERY component you build.

## Design System — CRITICAL
The mockup uses a specific design language you MUST replicate exactly:
- **Palette:** Deep charcoal #0C0B0F base, #141318 surfaces, #1A191F cards, #E8672A ember accent, #D4A847 gold accent, #4ADE80 success, #7C9CBF info
- **Typography:** Instrument Serif (serif, for company names/headings), DM Sans (body), JetBrains Mono (data/scores). Load via Google Fonts.
- **Borders:** rgba(255,255,255,0.06) subtle, rgba(255,255,255,0.1) medium
- **Text:** #EDEADF primary, rgba(237,234,223,0.6) secondary, rgba(237,234,223,0.35) muted

## What to Build (in order)

### 1. Design tokens + global styles
Create a Tailwind v4 theme with all the Forge palette colors, fonts, and spacing. Add Google Fonts link in index.html.

### 2. Zustand store (src/stores/appStore.ts)
- leads: Lead[] with mock data (use the companies from the mockup: Disney, Marriott, Hilton, Brinker, Darden, MGM, etc.)
- selectedLeadId: string | null
- filters: { search, status, scoreRange }
- copilotMode: draft | enrich | respond | research
- Mock 7+ leads with realistic data including contacts (Decision Makers), scores, enrichment data, permits

### 3. Sidebar (LeadListPanel)
- Search box with ember focus border
- Filter chips (All/Hot/New/Qualified) with ember active state
- Lead cards showing: company name, lead score (hot/warm/cool color), contractor, $ value, sqft, status dot, verified count
- Selected state with left ember bar indicator
- Footer with lead count + "+ New Lead" button

### 4. Center Panel (LeadProfileView)
This is the most complex. Build EXACTLY like the mockup:
- **Header:** Company icon, Instrument Serif name + score badge, meta line (owner, location, contractor), status pill, est. furniture value
- **Project stats row:** 4 stat cards (Project Size, Square Feet, Permit Type, Filed Date) with colored icons
- **Lead Score Breakdown:** Horizontal progress bars with gradient fills (bar-ember, bar-gold, bar-success, bar-info) showing WHY the lead scored high. Labels on left, values on right.
- **Decision Makers:** Contact cards with avatar circles (gradient backgrounds), name + confidence %, title, action buttons (phone/email/LinkedIn)
- **Enrichment Insights:** Tag chips grouped by category (Business Challenges, Technology Stack, AI-Identified Signals)
- **Recent Permits table:** Property, Type, Value (gold mono), Date

### 5. Copilot Panel (right)
- Header with pulsing green dot
- Tab row (Proposal/Email/Reply/Research) with ember active
- Context tags showing current lead data
- AI message area with draft proposal content
- Input bar with send button

### 6. Titlebar
- Logo mark (TT gradient), Instrument Serif "LeadForge" title
- Top nav (Leads/Pipeline/Proposals)
- Stats bar (Hot count, Pipeline value, Permits count)
- Bottom ember glow line

### 7. Bottom bar
- Keyboard shortcuts (⌘K, ⌘N, ⌘E, ⌘⇧P)
- Integration status indicators

## Technical Requirements
- Use Tailwind utility classes where possible, custom CSS only for complex effects (gradients, animations, score bars)
- All components in src/components/ with clear names
- Types in src/types/
- Zustand store in src/stores/
- Stagger animations on mount (fadeInUp with delay)
- Scrollable center panel, fixed sidebar heights
- Keep existing services (api.ts, leads.ts, ai.ts) intact — just swap the App.tsx shell

## DO NOT
- Do not use shadcn or any external UI library
- Do not change the color palette or fonts — match the mockup exactly
- Do not skip the score breakdown bars or decision makers section
- Do not use placeholder text where the mockup has real content

Build it all. Commit when done.
