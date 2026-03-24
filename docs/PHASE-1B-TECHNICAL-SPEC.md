# TableTopics Phase 1B — Technical Specification
## RFQ Entry → Syspro Quotation Pipeline

**Version:** 1.0  
**Date:** 2026-03-23  
**Status:** Draft  
**Author:** Daneel (Technical Lead)

---

## 1. Overview

### Current Workflow (manual)
1. Receive RFQ email from sales rep or customer
2. Enter details into Excel pricing spreadsheet ("Quote Pricing 2026")
3. Manually calculate unit prices using spreadsheet formulas
4. Manually enter each line item into Syspro 8.2022 Quotation Entry
5. Run Product Configuration Wizard per line item
6. Print/email quote from Syspro

### Phase 1B Workflow (automated)
1. Receive RFQ email → paste into app (or type manually)
2. App parses customer info + line items
3. Built-in pricing engine calculates live unit prices
4. User reviews quote preview
5. One click → pushes Quotation Header + Lines to Syspro via REST API
6. Syspro generates formal quote document

**Goal:** Eliminate steps 2–5 entirely. Cut quote turnaround from ~30 min to ~5 min.

---

## 2. Architecture

### Stack
- **Framework:** Tauri 2 + React + TypeScript (matches Phase 1A)
- **Backend:** Rust (Tauri commands for Syspro API calls, pricing engine)
- **Frontend:** React with existing UI component library from Phase 1A
- **Syspro Integration:** REST API on `tt-syspro:31002`

### Module Layout
```
src/
├── modules/
│   ├── rfq/
│   │   ├── RFQEntryView.tsx        # Main RFQ entry form
│   │   ├── RFQLineItem.tsx         # Individual line item component
│   │   ├── RFQParser.tsx           # Smart email paste parser
│   │   └── QuotePreview.tsx        # Preview before Syspro push
│   ├── pricing/
│   │   ├── PricingEngine.ts        # Core calculation logic
│   │   ├── PriceGroups.ts          # Wood category → price code lookup
│   │   ├── SizeMatrix.ts           # Size → base price lookup tables
│   │   └── Modifiers.ts            # Resin, gloss, trim, discount modifiers
│   └── syspro/
│       ├── SysproClient.ts         # REST API client wrapper
│       ├── QuotationAPI.ts         # Quotation CRUD operations
│       ├── CustomerAPI.ts          # Customer lookup
│       └── ConfiguratorAPI.ts      # Product configurator integration
src-tauri/
├── src/
│   ├── syspro/
│   │   ├── mod.rs                  # Syspro module
│   │   ├── client.rs               # HTTP client for Syspro REST
│   │   ├── quotation.rs            # Quotation header/line creation
│   │   └── configurator.rs         # Product config wizard integration
│   └── pricing/
│       ├── mod.rs                  # Pricing module
│       ├── engine.rs               # Rust-side pricing calculations
│       └── tables.rs               # Embedded pricing lookup tables
```

---

## 3. Data Model

### 3.1 RFQ (Request for Quote)

```typescript
interface RFQ {
  id: string;                    // UUID
  createdAt: string;             // ISO 8601
  status: 'draft' | 'priced' | 'submitted' | 'confirmed';

  // Customer info
  customer: {
    name: string;                // e.g., "Walt Disney World Resort"
    address: string;
    contact: string;
    salesRep: string;            // e.g., "Marc Zamore"
    salesRepCompany: string;     // e.g., "John Kenney Company"
    csr: string;                 // Internal CSR, e.g., "LeeAnna Hanes"
    customerPO: string;
    email: string;
    phone: string;
    fax: string;
    communicationPreference: 'fax' | 'email' | 'none';
  };

  // Quote metadata
  description: string;           // e.g., "Disney's Caribbean Beach Resort"
  terms: string;                 // e.g., "Net 30"
  fob: string;                   // e.g., "Factory"
  leadtimeWeeks: number;         // e.g., 8

  // Line items
  lineItems: RFQLineItem[];

  // Pricing
  discount: number;              // Global discount multiplier (0.0–1.0)
  totalAmount: number;           // Calculated

  // Syspro reference (after push)
  sysproQuotationNumber: string | null;
  sysproStatus: 0 | 1 | 2 | 4 | null;  // Prep/Ready/Printed/Confirmed
}
```

### 3.2 RFQ Line Item

```typescript
interface RFQLineItem {
  id: string;
  lineNumber: number;

  // Dimensions
  width: number;                 // inches
  length: number;                // inches
  sizeLabel: string;             // derived: "24.00\" x 30.00\""
  thickness: '1.5' | '1.75';    // inches — 1½" or 1¾"
  isRound: boolean;
  roundHeight: number | null;    // Height for round tables

  // Product configuration
  productType: ProductType;       // Maps to Syspro configurator code
  woodCategory: WoodCategory;
  woodType: WoodType;
  finishType: FinishType;
  edgeProfile: EdgeProfile;
  stainOption: string;
  plankDirection: 'random' | 'parallel' | 'perpendicular';

  // Modifiers
  metalTrim: boolean;
  solidColor: boolean;
  distress: DistressLevel;
  resin: boolean;                 // +$20/sq ft
  gloss: boolean;                 // +$11/sq ft
  marquetryType: 'none' | 'I' | 'II';

  // Multi-offer support (Syspro supports up to 5 per line)
  offers: Offer[];

  // Reference
  matchPreviousOrder: string | null;  // e.g., "1710053"
  matchSampleNumber: string | null;
  notes: string;

  // Calculated
  squareFeet: number;            // width * length / 144
  squareInches: number;
  perimeter: number;             // 2*(width+length) in inches
  runningFeet: number;           // perimeter / 12
  unitPrice: number;             // From pricing engine
  lineTotal: number;             // unitPrice * quantity
}

interface Offer {
  offerNumber: number;           // 1–5
  quantity: number;
  unitPrice: number;
  value: number;                 // quantity * unitPrice
  markupPercent: number;         // Default 70.00
  routing: string;               // e.g., "C-Low"
}
```

### 3.3 Enums / Lookup Types

```typescript
// Syspro Product Configurator codes (from scanned photos)
type ProductType =
  | 'V3'   // Veneer to Edge
  | 'V1'   // Veneers (Simple)
  | 'V2'   // Veneers (standard)
  | 'SW'   // Solid Woods
  | 'SW2'  // Solid Woods 2
  | 'BB'   // Barnboards
  | 'DE'   // Digital to Edge
  | 'DF'   // Digital with Frame
  | 'EV'   // Exotic Veneers to Edge
  | 'LAM'  // Laminates
  | 'SC'   // Solid Color Painted
  | 'VNL'  // Vinyl
  | 'WB_CL' | 'WB_CY' | 'WB_P' | 'WB_T' | 'WB_WC';  // Wood Bases

// Wood category codes (from Cost_calc Price Groups)
type WoodCategory =
  | 106   // Aromatic Cedar/Pine Frame
  | 101   // Knotty Pine
  | 110   // Ash Veneer
  | 120   // Oak Veneer
  | 130   // Maple Veneer
  | 150   // Cherry Veneer
  | 140   // Mahogany Veneer
  | 160   // Walnut Veneer
  | 111   // Ash Diamond Box
  | 121   // Oak Diamond Box
  | 131   // Maple Diamond Box
  | 151   // Cherry Diamond Box
  | 141   // Mahogany Diamond Box
  | 161   // Walnut Diamond Box
  | 116   // Distressed Barnboards
  | 113   // Ash Sunburst
  | 123   // Oak Sunburst
  | 133   // Maple Sunburst
  | 153   // Cherry Sunburst
  | 143   // Mahogany Sunburst
  | 163   // Walnut Sunburst
  | 190   // Exotic Veneer (+2.5x cost)
  | 210   // Laminate Open Grain (+2.5x cost)
  | 220;  // Metal Full Fill (+2.5x cost)

type FinishType =
  | 'acralyte_satin' | 'acralyte_matte' | 'acralyte_gloss'
  | 'solid_color'
  | 'marquetry_I' | 'marquetry_II'
  | 'resin'
  | 'digital_acralyte' | 'digital_to_edge' | 'digital_with_frame'
  | 'digital_metallic_bg' | 'digital_acid_wash'
  | 'laminate' | 'metal';

type EdgeProfile =
  | 'eased' | 'ogee' | 'bevel' | 'fillet'
  | 'hewn' | 'scalloped' | 'classic';

type DistressLevel = 'none' | 'light' | 'medium' | 'heavy';
```

---

## 4. Pricing Engine

### 4.1 Calculation Flow

Replicates the Excel spreadsheet ("Quote Pricing 2026") logic:

```
Base Price (from size matrix + style/price code)
  + Frame Cost (from wood category)
  + Edge Profile surcharge (if premium)
  + Metal Trim (if selected)
  + Solid Color surcharge (if selected)
  + Distress surcharge (if selected)
  + Resin add-on ($20/sq ft × square footage)
  + Gloss add-on ($11/sq ft × square footage)
  + Marquetry trim (I or II pricing tier)
  × Discount multiplier
  = Unit Price
```

### 4.2 Size → Base Price Matrix

From Cost_calc (Acralyte tab). Extracted values:

| Size | Base Price |
|------|-----------|
| 24×24 | $429 |
| 24×30 | — |
| 24×36 | — |
| 24×42 | — |
| 24×48 | — |
| 30×30 | $543 |
| 30×36 | $705 |
| 30×42 | $898 |
| 30×48 | $1,149 |
| 30×54 | $1,404 |
| 30×60 | $1,776 |
| 30×72 | — |
| 30×84 | $2,083 |
| 30×96 | $2,669 |
| 36×36 – 36×96 | — |
| 42×42 | $970 |
| 48×48 | — |
| **Round** | |
| 30×30×42 | $1,618 |
| 36×36×51 | $2,502 |
| 42×42×60 | $2,937 |

> **⚠️ BLOCKER:** Many base prices not visible in PDF extraction. Need Hayden to export full `.xlsx` workbook. The core formula `=IF($I$11="I",AZ18,IF($I$11="J",BA18,IF($I$11="K",BB18,0)))*$B$10` shows prices are conditional on style code columns (AZ=I, BA=J, BB=K) multiplied by a factor in B10.

### 4.3 Price Groups Lookup

Maps wood category → Deluxe/Budget price code:

```typescript
const PRICE_GROUPS: Record<number, { deluxe: string; budget: string }> = {
  106: { deluxe: '1C', budget: '2C' },  // Aromatic Cedar/Pine
  101: { deluxe: '1C', budget: '2C' },  // Knotty Pine
  110: { deluxe: '1C', budget: '2C' },  // Ash Veneer
  120: { deluxe: '1D', budget: '2D' },  // Oak Veneer
  130: { deluxe: '1D', budget: '2D' },  // Maple Veneer
  150: { deluxe: '1D', budget: '2D' },  // Cherry Veneer
  140: { deluxe: '1E', budget: '2E' },  // Mahogany Veneer
  160: { deluxe: '1E', budget: '2E' },  // Walnut Veneer
  111: { deluxe: '1F', budget: '2F' },  // Ash Diamond Box
  121: { deluxe: '1F', budget: '2F' },  // Oak Diamond Box
  131: { deluxe: '1F', budget: '2F' },  // Maple Diamond Box
  151: { deluxe: '1F', budget: '2F' },  // Cherry Diamond Box
  141: { deluxe: '1F', budget: '2F' },  // Mahogany Diamond Box
  161: { deluxe: '1F', budget: '2F' },  // Walnut Diamond Box
  116: { deluxe: '1F', budget: '2F' },  // Distressed Barnboards
  113: { deluxe: '1G', budget: '2G' },  // Ash Sunburst
  123: { deluxe: '1G', budget: '2G' },  // Oak Sunburst
  133: { deluxe: '1G', budget: '2G' },  // Maple Sunburst
  153: { deluxe: '1G', budget: '2G' },  // Cherry Sunburst
  143: { deluxe: '1G', budget: '2G' },  // Mahogany Sunburst
  163: { deluxe: '1G', budget: '2G' },  // Walnut Sunburst
  190: { deluxe: '1D', budget: '2D' },  // Exotic (+2.5x veneer cost)
  210: { deluxe: '1D', budget: '2D' },  // Laminate Open Grain (+2.5x)
  220: { deluxe: '1F', budget: '2F' },  // Metal Full Fill (+2.5x)
  // Mystic Metal Aluminum → 1G/2G
  // Acid Wash → 1H/2H
};
```

### 4.4 Finish Category Codes (from spreadsheet)

| Code | Finish |
|------|--------|
| 310 | Solid Color |
| 330 | Digital Acralyte / Digital Print to Edge |
| 331 | Digital over Wood — Wood Category + Marquetry Trim 1 |
| 410–620 | Various specialty finishes |

### 4.5 Modifier Pricing

```typescript
const MODIFIERS = {
  resinPerSqFt: 20.00,
  glossPerSqFt: 11.00,
  customStainMatchFee: 125.00,   // One-time fee per quote
  defaultMarkup: 70.00,          // Syspro default markup %
};
```

---

## 5. Syspro REST API Integration

### 5.1 Connection

```typescript
const SYSPRO_CONFIG = {
  host: 'tt-syspro',
  restPort: 31002,
  soapPort: 31001,           // Fallback only
  baseUrl: 'http://tt-syspro:31002',
  // Auth: Syspro operator credentials — TBD from Hayden
};
```

### 5.2 API Endpoints (Syspro 8.2022 REST)

| Operation | Method | Endpoint | Purpose |
|-----------|--------|----------|---------|
| Create Quote Header | POST | `/api/Quotation` | New quotation |
| Add Quote Line | POST | `/api/QuoteLine` | Line item with offers |
| Get Customer | GET | `/api/Customer/{id}` | Customer lookup |
| Get Stock Code | GET | `/api/StockCode/{code}` | Product lookup |
| Configure Product | POST | `/api/ProductConfigurator` | Run config wizard |
| Update Quote Status | PUT | `/api/Quotation/{id}/Status` | Status transitions |
| List Quotes | GET | `/api/Quotation` | Query existing |

> **Note:** Exact endpoint paths need verification against Syspro 8.2022 docs. Check `http://tt-syspro:31002/swagger` if enabled.

### 5.3 Quotation Creation Flow

```
1. GET /api/Customer/{code}        — Verify customer exists
2. POST /api/Quotation             — Create header → returns quotation #
3. For each line item:
   a. POST /api/ProductConfigurator
      → Config code (e.g., "V3"), wood/finish/edge selections
      → Returns stock code (e.g., "OPQ-0101")
   b. POST /api/QuoteLine
      → Quotation #, line #, stock code, description
      → For each offer: qty, unit price, markup (70%), routing ("C-Low")
4. PUT /api/Quotation/{id}/Status  → Set to 0 (Preparation)
```

### 5.4 Syspro Data Structures

```typescript
// From Syspro Quotation Entry screenshots
interface SysproQuotationHeader {
  quotationNumber: string;         // Auto-generated
  description: string;
  customer: string;                // Customer code
  customerName: string;
  salesOrderNumber: string | null; // Linked SO# (Phase 2)
  pricingWorksheet1: string;
  pricingWorksheet2: string;
  pricingWorksheet3: string;
  customerPO: string;
  contact: string;
  telephone: string;
  fax: string;
  email: string;
  communicationPreference: 'F' | 'E' | 'N';
  status: 0 | 1 | 2 | 4;
}

interface SysproQuotationLine {
  lineNumber: number;
  lineType: 'N';                  // Non-Stocked (all custom tables)
  stockCode: string;              // From configurator, e.g., "OPQ-0101"
  stockDescription: string;
  longDescription: string;        // Full spec
  warehouse: string;
  configurationCode: string;      // e.g., "V3"
  offers: SysproOffer[];
}

interface SysproOffer {
  offerNumber: number;
  quantity: number;
  unitPrice: number;
  value: number;
  markupPercent: number;          // 70.00 default
  routing: string;                // "C-Low"
}
```

---

## 6. UI Design

### 6.1 RFQ Entry View — Three-Panel Layout

```
┌──────────────────────────────────────────────────────────────────┐
│  RFQ Entry                                            [Preview] │
├─────────────────────┬────────────────────────────────────────────┤
│                     │                                            │
│  CUSTOMER INFO      │  LINE ITEMS                                │
│  ────────────────   │  ──────────────────────────────────────── │
│  Customer ▼         │  ┌─ Item 1 ─────────────────────────────┐ │
│  Name: [_________]  │  │ 24×30  Solid Ash  Acralyte Matte     │ │
│  Contact: [______]  │  │ Eased Edge · Random Plank            │ │
│  Sales Rep: [____]  │  │ Qty: 6 × $390.00 = $2,340.00        │ │
│  CSR: [__________]  │  │ [Edit] [Duplicate] [Remove]          │ │
│  PO#: [__________]  │  └──────────────────────────────────────┘ │
│  Terms: [Net 30 ▼]  │  ┌─ Item 2 ─────────────────────────────┐ │
│  FOB: [Factory  ▼]  │  │ 30×48  Solid Ash  Acralyte Matte     │ │
│  Lead Time: [8] wk  │  │ Eased Edge · Random Plank            │ │
│                     │  │ Qty: 2 × $709.00 = $1,418.00         │ │
│  SMART PASTE        │  └──────────────────────────────────────┘ │
│  ────────────────   │                                            │
│  [Paste RFQ Email]  │  [+ Add Line Item]                        │
│                     │                                            │
│  DISCOUNT           │  ─────────────────────────────────────── │
│  ────────────────   │  Subtotal:         $7,526.00             │
│  [___] %            │  Discount (0%):         $0.00             │
│                     │  TOTAL:            $7,526.00             │
│                     │                                            │
│                     │  [Save Draft]  [Push to Syspro →]        │
└─────────────────────┴────────────────────────────────────────────┘
```

### 6.2 Line Item Editor (Modal)

```
┌─ New Line Item ──────────────────────────────────────┐
│                                                       │
│  SIZE                      PRODUCT TYPE               │
│  Width:  [24] in           [Veneer to Edge      ▼]   │
│  Length: [30] in           Config: V3                 │
│  Thick:  [1.75▼] in                                  │
│  □ Round table                                        │
│                                                       │
│  WOOD                      FINISH                     │
│  Category: [Ash Veneer ▼]  Type: [Acralyte Matte ▼] │
│  Code: 110 → Price: 1C    □ Resin (+$20/sf)          │
│                            □ Gloss (+$11/sf)          │
│  EDGE           PLANK      Marquetry: [None ▼]       │
│  [Eased    ▼]  [Random▼]                             │
│                                                       │
│  OPTIONS                                              │
│  □ Metal Trim  □ Solid Color  Distress: [None ▼]    │
│  Stain: [Match Previous Order____________]            │
│  Match Order#: [1710053___]                           │
│  Match Sample#: [________]                            │
│                                                       │
│  OFFERS                                               │
│  ┌─ Offer 1 ────────────────────────────────────┐    │
│  │ Qty: [6]  Price: $390.00  = $2,340.00        │    │
│  │ Markup: [70.00]%  Routing: [C-Low]           │    │
│  └──────────────────────────────────────────────┘    │
│  [+ Add Offer]                                        │
│                                                       │
│  Sq Ft: 5.00 | Perimeter: 108" | RunFt: 9.00        │
│  UNIT PRICE: $390.00                                  │
│                                                       │
│  [Cancel]                      [Add to Quote]        │
└───────────────────────────────────────────────────────┘
```

### 6.3 Smart RFQ Parser

Paste raw email text → extract structured data:

```typescript
interface ParsedRFQ {
  confidence: number;              // 0–1, warn if < 0.7
  customer: Partial<RFQ['customer']>;
  lineItems: Partial<RFQLineItem>[];
  rawText: string;
  unmatchedSegments: string[];     // Parts we couldn't parse
}
```

Parser strategy:
- Regex for table sizes ("24 x 30", "24×30", "24\" x 30\"")
- Keyword matching for wood types, finishes, edge profiles
- Customer name/address from email header
- Quantity detection ("qty 6", "6 units", "6 ea")
- Falls back to manual entry for anything ambiguous

### 6.4 Quote Preview

Matches existing printed quote format before Syspro push. Shows all line items with full spec descriptions, totals, terms, and the custom stain match fee note when applicable.

---

## 7. Data Requirements from Client

### Critical (blocks development)
- [ ] **Full Excel export** — "Quote Pricing 2026" workbook as `.xlsx`. We need ALL price columns (AZ–BB+) for every size row and style code
- [ ] **Syspro REST API credentials** — Operator username/password or API token for `tt-syspro:31002`
- [ ] **Syspro API documentation** — or confirm Swagger at `http://tt-syspro:31002/swagger`
- [ ] **Product Configurator code list** — Complete mapping of codes to product types (we confirmed V3 = Veneer to Edge; need all)

### Important (can start without, need before testing)
- [ ] **Test customer account** in Syspro
- [ ] **Stock code naming convention** — How are OPQ-xxxx codes generated?
- [ ] **Default warehouse code**
- [ ] **Confirm markup/routing** — 70% markup + "C-Low" routing standard for all?

### Nice to have
- [ ] 3–5 sample RFQ emails for parser training
- [ ] Customer list export for autocomplete
- [ ] Existing Syspro integration code (if any)

---

## 8. Implementation Plan

| Phase | Scope | Duration | Dependencies |
|-------|-------|----------|-------------|
| **1B-1** | Pricing Engine | Week 1–2 | Excel export from Hayden |
| **1B-2** | RFQ Entry UI | Week 2–3 | None (can use placeholder prices) |
| **1B-3** | Syspro Integration | Week 3–4 | API credentials, test account |
| **1B-4** | Polish & Testing | Week 4 | All above |

### 1B-1: Pricing Engine (Week 1–2)
- Size matrix lookup tables (from Excel export)
- Price Groups mapping
- Modifier calculations (resin, gloss, trim, marquetry)
- Style code conditional pricing formula
- Unit tests against known quote values

### 1B-2: RFQ Entry UI (Week 2–3)
- Customer info panel with Syspro autocomplete
- Line item CRUD (add, edit, duplicate, remove)
- Live pricing display (recalcs on every change, <50ms target)
- Offer management per line
- Save/load drafts locally
- Smart email parser (stretch goal)

### 1B-3: Syspro Integration (Week 3–4)
- REST client wrapper (Rust/Tauri commands)
- Customer lookup
- Quotation creation (header + lines + configurator)
- Status tracking
- Error handling and retry

### 1B-4: Polish & Testing (Week 4)
- Quote preview matching existing format
- End-to-end testing with Syspro
- Edge cases: round tables, exotic veneers (+2.5x), custom sizes

---

## 9. Validation Data

Disney Caribbean Beach Resort quote (Q#00017469 / SO#2602039) as ground truth:

| Size | Wood | Finish | Edge | Qty | Unit Price | Total |
|------|------|--------|------|-----|-----------|-------|
| 24×30 | Solid Ash | OG Acralyte Matte | Eased | 6 | $390.00 | $2,340.00 |
| 30×48 | Solid Ash | OG Acralyte Matte | Eased | 2 | $709.00 | $1,418.00 |
| 34×34 | Solid Ash | OG Acralyte Matte | Eased | 2 | $580.00 | $1,160.00 |
| 30×72 | Solid Ash | OG Acralyte Matte | Eased | 1 | $1,110.00 | $1,110.00 |
| 30×96 | Solid Ash | OG Acralyte Matte | Eased | 1 | $1,498.00 | $1,498.00 |
| | | | | **Total** | | **$7,526.00** |

All items: Random Width Planking, 1.75" Thick, Match Previous Order 1710053.  
Stock codes: OPQ-0101, OPQ-0105, OPQ-0103, OPQ-104 (inconsistent zero-padding).  
Sales Order: #2602039, Ship date: 04/03/26, Jobs: 00029490–00029494.

**Pricing engine MUST reproduce these exact prices to be considered correct.**

---

## 10. Risks & Open Questions

| # | Risk / Question | Impact | Mitigation |
|---|----------------|--------|------------|
| 1 | Incomplete pricing data from PDF extraction | Can't calculate prices accurately | **Need Excel export from Hayden** — #1 blocker |
| 2 | Syspro REST API auth/access unknown | Integration blocked | Request credentials + test endpoint early |
| 3 | Product Configurator may require SOAP, not REST | Extra development effort | Check if REST wrapper exists; SOAP fallback via port 31001 |
| 4 | Stock code generation logic unclear | Can't create valid line items | Ask Hayden for convention; may be auto-generated by configurator |
| 5 | Multi-offer pricing interactions | Offer-level discounts may cascade | Verify offer isolation in Syspro test environment |
| 6 | Custom/non-standard sizes not in matrix | Pricing gaps | Implement interpolation or flag for manual pricing |
| 7 | Network access to tt-syspro from Tauri app | App can't reach Syspro | Confirm LAN access; may need VPN config |

---

## 11. Deferred to Phase 2

- Sales order conversion (quotation → SO)
- Production scheduling / job tracking
- Email sending from app
- Invoice generation
- Order status dashboard
- Historical quote search/analytics

---

*This spec will be updated once Hayden provides the Excel workbook and Syspro API credentials.*
