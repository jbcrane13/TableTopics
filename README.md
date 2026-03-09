# Table Topics

iOS app for finding hotel and restaurant contractors who need tables.

## Overview

Table Topics is a lead generation app for **Table Topics** - a company selling tables to contractors building hotels and restaurants. The app uses the Shovels.ai API to find contractors with active permits in the hospitality sector.

## Features

- **Contractor Search**: Find contractors by type (restaurant furniture, hotel renovation, bar furniture, etc.)
- **Area Lock**: Restrict all searches to a specific city or state
- **Lead Scoring**: Automatic scoring based on project value, completion rate, contact quality, timing, and similar projects
- **API Integration**: Shovels.ai API for real permit data (250 free credits)

## Building

```bash
cd ios
xcodegen generate
xcodebuild -scheme TableTopics -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build
```

## Architecture

- **B2BPlatform**: Shared Swift Package (B2BCore + B2BUI)
- **TableTopics app**: iOS app with TabView (Leads + Search)
- **Shovels.ai API**: Real-time contractor and permit data

## Data Sources

- **Shovels.ai**: Contractor licenses, permits, project history
- **Mock Data**: Built-in demo data for testing without API credits

## Credits

Free tier: 250 credits
- Each search: ~6 credits per result (1 contractor + 5 permits)
- Conservative limit: 10 results = ~60 credits per search
- ~4 searches available on free tier

## Future

- AI Table Design Tool (Phase 2)
- Quote generation
- CRM integration