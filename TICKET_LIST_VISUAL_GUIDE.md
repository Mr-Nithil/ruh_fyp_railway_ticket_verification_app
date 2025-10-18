# Ticket List Screen - Visual Component Guide

## Screen Hierarchy

### 🎯 Ticket List Screen Layout

```
┌─────────────────────────────────────┐
│  ◀  Ticket List               [12]  │ ← Header (Green Gradient)
│     View all bookings...            │
├─────────────────────────────────────┤
│  🚂  Yaal Devi Express              │ ← Train Info Card
│     Colombo Fort → Jaffna           │
├─────────────────────────────────────┤
│                                     │
│  ┌───────────────────────────────┐ │
│  │ ✓ APPROVED              #1    │ │ ← Status Bar
│  ├───────────────────────────────┤ │
│  │ 👤 John Smith               ▶ │ │ ← Primary Passenger
│  │    Primary Passenger          │ │
│  │                               │ │
│  │ 👥 Passengers    📅 Travel    │ │ ← Info Grid
│  │    3                2024-10-15│ │
│  │                               │ │
│  │ ⏰ Departure     💰 Amount     │ │
│  │    08:30           Rs. 1500   │ │
│  │                               │ │
│  │ ✓ Checked by John Doe         │ │ ← Checker Info
│  └───────────────────────────────┘ │
│                                     │
│  ┌───────────────────────────────┐ │
│  │ ⚠ PENDING               #2    │ │ ← Another Ticket
│  │ ...                           │ │
│  └───────────────────────────────┘ │
│                                     │
└─────────────────────────────────────┘
```

### 📋 Ticket Detail Screen Layout

```
┌─────────────────────────────────────┐
│           ✓ APPROVED                │ ← Status Header
│      Booking Details                │   (Green Gradient)
│                                     │
├─────────────────────────────────────┤
│  Booking Information                │
│  ┌───────────────────────────────┐ │
│  │ 📄 Booking ID                 │ │
│  │    abc123...                  │ │
│  └───────────────────────────────┘ │
│                                     │
│  Journey Details                    │
│  ┌───────────────────────────────┐ │
│  │ 🚂 Train                      │ │
│  │    Yaal Devi Express          │ │
│  └───────────────────────────────┘ │
│  ┌───────────────────────────────┐ │
│  │ 📍 Route                      │ │
│  │    Colombo Fort → Jaffna      │ │
│  └───────────────────────────────┘ │
│                                     │
│  Passengers                     [3] │
│  ┌───────────────────────────────┐ │
│  │ 👤 John Smith      [PRIMARY]  │ │
│  │    Male • Age: 35 • Seat: A12 │ │
│  │    First Class                │ │
│  │    🎫 NIC: 123456789V         │ │
│  └───────────────────────────────┘ │
│                                     │
│  Payment Details                    │
│  ┌───────────────────────────────┐ │
│  │ 💰 Total Amount               │ │
│  │    Rs. 1,500.00               │ │
│  └───────────────────────────────┘ │
│                                     │
│  Verification Details               │
│  ┌───────────────────────────────┐ │
│  │ Checked by: John Doe          │ │
│  │ Time: 10:30 AM                │ │
│  │ Remark: All verified          │ │
│  └───────────────────────────────┘ │
│                                     │
│  [◀ Back to List]                  │
│                                     │
└─────────────────────────────────────┘
```

## Component Breakdown

### 1. Status Indicators

#### Visual Design:
```
┌─────────────────────────────┐
│ ✓ APPROVED            (Green)│  ← Approved
├─────────────────────────────┤
│ ⚠ PENDING            (Orange)│  ← Pending Review
├─────────────────────────────┤
│ ✕ REJECTED              (Red)│  ← Rejected
├─────────────────────────────┤
│ ⚠ INACTIVE USER      (Orange)│  ← User Inactive
├─────────────────────────────┤
│ ⛔ FRAUD                 (Red)│  ← Fraud Confirmed
└─────────────────────────────┘
```

### 2. Info Card Pattern

Used throughout the app:
```
┌───────────────────────────────┐
│ [🎨]  Label                   │  ← Gradient icon bg
│       Value Text              │  ← Bold value
└───────────────────────────────┘
```

Colors by section:
- 🔵 Blue: Booking/Reference info
- 🟢 Green: Journey details
- 🟣 Purple: Passenger info
- 🟡 Amber: Payment info
- 🔷 Indigo: Contact info

### 3. Passenger Card

```
┌───────────────────────────────────┐
│ [👤] John Smith      [PRIMARY]    │  ← Name + Badge
│      Male • Age: 35 • Seat: A12   │  ← Demographics
│      First Class                  │  ← Class
│                                   │
│      🎫 NIC: 123456789V           │  ← ID (if available)
└───────────────────────────────────┘
```

Badges:
- `[PRIMARY]` - Purple badge for primary passenger
- `[DEPENDENT]` - Orange badge for dependents

### 4. Empty States

#### No Tickets:
```
┌─────────────────────────────┐
│                             │
│          📥                 │  ← Large icon
│                             │
│    No Tickets Found         │  ← Bold title
│                             │
│  There are no bookings...   │  ← Description
│                             │
│     [🔄 Refresh]            │  ← Action button
│                             │
└─────────────────────────────┘
```

#### Loading:
```
┌─────────────────────────────┐
│                             │
│          ⏳                 │  ← Spinner
│                             │
│   Loading tickets...        │  ← Status text
│                             │
└─────────────────────────────┘
```

#### Error:
```
┌─────────────────────────────┐
│                             │
│          ⚠️                 │  ← Error icon
│                             │
│  Failed to Load Tickets     │  ← Error title
│                             │
│  Unable to fetch data...    │  ← Error message
│                             │
│     [🔄 Retry]              │  ← Retry button
│                             │
└─────────────────────────────┘
```

## Color Palette

### Status Colors:
- **Approved**: `Colors.green` (hex: #4CAF50)
- **Rejected/Fraud**: `Colors.red` (hex: #F44336)
- **Pending/Warning**: `Colors.orange` (hex: #FF9800)

### Section Colors (Gradients):
- **Header**: Green.shade600 → Green.shade800
- **Booking Info**: Blue.shade400 → Blue.shade600
- **Journey Info**: Green.shade400 → Green.shade600
- **Passenger Info**: Purple.shade400 → Purple.shade600
- **Payment Info**: Amber.shade400 → Amber.shade600
- **Contact Info**: Indigo.shade400 → Indigo.shade600

### Background Colors:
- **Screen**: `Colors.grey[50]` (Off-white)
- **Cards**: `Colors.white`
- **Secondary**: `Colors.grey[100]`

## Typography Scale

```
┌────────────────────────────────┐
│ Page Title           28px  w800│  ← Headers
│ Section Title        20px  w700│  ← Section headers
│ Card Title           16px  w700│  ← Card titles
│ Body Text            14-16px   │  ← Regular text
│ Small Text           11-13px   │  ← Labels, hints
│ Badge Text           10px  w700│  ← Badges, chips
└────────────────────────────────┘
```

## Spacing System

```
Consistent spacing throughout:
- Card padding:    16px
- Card margin:     16-20px horizontal
- Section gaps:    28px vertical
- Item gaps:       12-16px
- Small gaps:      4-8px
- Border radius:   12-16px
```

## Shadow System

```
Card Shadows:
BoxShadow(
  color: Colors.black.withOpacity(0.06),
  blurRadius: 15,
  offset: Offset(0, 3),
)

Header Shadows:
BoxShadow(
  color: Colors.black.withOpacity(0.2),
  blurRadius: 10,
  offset: Offset(0, 4),
)
```

## Animation Opportunities

Potential additions:
- 🎬 Fade in animation for cards
- 🎬 Slide animation for navigation
- 🎬 Ripple effect on card tap
- 🎬 Shimmer for loading states
- 🎬 Status badge pulse effect

---

This guide provides a visual reference for maintaining consistency when extending the ticket list functionality!
