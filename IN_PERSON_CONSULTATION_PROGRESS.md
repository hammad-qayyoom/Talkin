# In-Person Consultation Feature - Progress Tracker

**Project:** Notisboard (TalkIn)
**Feature:** In-Person Consultation
**Start Date:** 2026-07-19
**Last Updated:** 2026-07-19
**Status:** Implementation Complete — Testing & QA Pending

---

## Executive Summary

The In-Person Consultation feature extends the existing Online Consultation system to support face-to-face expert sessions at physical clinic locations. The implementation follows a **"branch, don't duplicate"** philosophy — all new code paths are parameterized by `consultationMode` (online | in_person), reusing the existing booking, payment, commission, notification, and scheduling systems. The `inPersonConsultationEnabled` setting acts as a master kill switch.

---

## Complete File Manifest

### Backend — Models (5 files modified)

| File | Changes |
|---|---|
| `sourcecode/admin/backend/models/v2/expertProfile.model.js` | Added `consultationModes`, `inPersonPricing`, `clinicDetails` sub-document, 3 new indexes |
| `sourcecode/admin/backend/models/v2/expertAvailability.model.js` | Added `consultationMode` field, 2 new indexes |
| `sourcecode/admin/backend/models/v2/consultationSession.model.js` | Added `consultationMode`, `inPersonDetails.clinicSnapshot`, pre-validate normalization, 2 new indexes |
| `sourcecode/admin/backend/models/v2/sessionBooking.model.js` | Added `consultationMode`, `arrivalStatus`, `arrivedAt`, 2 new indexes |
| `sourcecode/admin/backend/models/setting.model.js` | Added 13 `inPerson*` global config fields |

### Backend — Controllers (3 files modified/created)

| File | Changes |
|---|---|
| `sourcecode/admin/backend/controllers/v2/expert.controller.js` | Modified `upsertExpertProfile`, `discoverExperts`, `listAvailabilitySlots`, `upsertAvailabilitySlots`; New `getExpertClinic` |
| `sourcecode/admin/backend/controllers/v2/session.controller.js` | Modified `createSession`, `bookSession`, `getAvailableSlots`; New `getBookingNavigation`, `markArrival`, `markSessionCompleted` |
| `sourcecode/admin/backend/controllers/admin/clinicManagement.controller.js` | **New file** — `listClinics`, `updateClinicApproval` |

### Backend — Routes (3 files modified/created)

| File | Changes |
|---|---|
| `sourcecode/admin/backend/routes/v2/expert.route.js` | Added `GET /clinic/:expertId` |
| `sourcecode/admin/backend/routes/v2/session.route.js` | Added `GET /navigation/:bookingId`, `POST /:bookingId/arrive`, `POST /:bookingId/complete` |
| `sourcecode/admin/backend/routes/admin/clinic.route.js` | **New file** — `GET /list`, `PATCH /approve` |
| `sourcecode/admin/backend/routes/admin/route.js` | Registered clinic routes with auth middleware |

### Admin Panel (11 files modified/created)

| File | Changes |
|---|---|
| `sourcecode/admin/frontend/src/views/settings/tabs/InPersonSettings.jsx` | **New file** — 10-field settings tab |
| `sourcecode/admin/frontend/src/views/settings/index.jsx` | Added "In-Person" tab, updated useEffect and renderTabContent |
| `sourcecode/admin/frontend/src/views/clinic-management/index.jsx` | **New file** — Clinic management view with approval workflow |
| `sourcecode/admin/frontend/src/app/(dashboard)/clinic-management/page.jsx` | **New file** — Next.js route page |
| `sourcecode/admin/frontend/src/views/sessions/index.jsx` | Added "Mode" column with Online/In-Person chips |
| `sourcecode/admin/frontend/src/views/listener/ListenerListTable.jsx` | Added "Modes" column showing consultation mode badges |
| `sourcecode/admin/frontend/src/components/layout/vertical/VerticalMenu.jsx` | Added "Clinic Management" menu item |
| `sourcecode/admin/frontend/src/config/moderatorPermissions.js` | Added `clinicManagement` permission key and route mapping |

### Mobile App — Flutter (9 files modified/created)

| File | Changes |
|---|---|
| `sourcecode/flutterapp/talkin/lib/utils/api.dart` | Added 4 endpoint constants: `expertClinic`, `sessionNavigation`, `sessionMarkArrival`, `sessionMarkCompleted` |
| `sourcecode/flutterapp/talkin/lib/ui/common/session_booking/session_booking_service.dart` | Added `consultationMode` to `getAvailableSlots()`, `bookSession()`, `setExpertAvailability()`; New `getExpertClinic()`, `getBookingNavigation()`, `markArrival()`, `markSessionCompleted()` |
| `sourcecode/flutterapp/talkin/lib/ui/user_flow/profile_detail_screen/model/listener_profile_response_model.dart` | Added `consultationModes`, `inPersonPricing`, `clinicDetails` to `ListenerData` |
| `sourcecode/flutterapp/talkin/lib/ui/user_flow/profile_detail_screen/widget/profile_detail_screen_widget.dart` | Online/In-Person badges, clinic preview card, in-person price tile, passes data to booking |
| `sourcecode/flutterapp/talkin/lib/ui/user_flow/session_booking_screen/view/user_book_session_screen.dart` | Consultation mode selection chips, clinic info card, mode-aware slot fetch and booking |
| `sourcecode/flutterapp/talkin/lib/ui/user_flow/home_screen/api/top_listeners_api.dart` | Added `consultationMode` to discover URI and `callApi()` |
| `sourcecode/flutterapp/talkin/lib/ui/user_flow/home_screen/controller/home_screen_controller.dart` | Added `selectedConsultationMode` state, `selectConsultationMode()` method |
| `sourcecode/flutterapp/talkin/lib/ui/user_flow/home_screen/widget/find_more_widget.dart` | Consultation mode filter chips (All/Online/In-Person) |
| `sourcecode/flutterapp/talkin/lib/ui/user_flow/my_sessions_screen/view/my_sessions_screen.dart` | Consultation mode badge, clinic info card, "Navigate to Clinic" button |

---

## Phase 1: Database Schema Changes ✅ COMPLETED

### New Fields Summary

**ExpertProfile (`expertProfile.model.js`):**
- `consultationModes.online` (Boolean, default: true)
- `consultationModes.inPerson` (Boolean, default: false)
- `inPersonPricing.currency` (String, default: "USD")
- `inPersonPricing.oneToOneSession` (Number, default: 0)
- `clinicDetails.clinicName` (String)
- `clinicDetails.address.{full, street, city, state, country, postalCode}` (String)
- `clinicDetails.coordinates` (GeoJSON Point with 2dsphere index)
- `clinicDetails.floorSuite`, `landmark`, `parkingInfo` (String)
- `clinicDetails.contactPhone`, `contactEmail` (String)
- `clinicDetails.consultationInstructions` (String)
- `clinicDetails.clinicPhotos[]` (Array of {url, caption, sortOrder})
- `clinicDetails.approvalStatus` (pending/approved/rejected, with index)
- `clinicDetails.approvedAt`, `approvedByAdminId`, `rejectionReason`

**ExpertAvailability (`expertAvailability.model.js`):**
- `consultationMode` (online | in_person, default: online, with 2 indexes)

**ConsultationSession (`consultationSession.model.js`):**
- `consultationMode` (online | in_person, default: online, with pre-validate normalization)
- `inPersonDetails.clinicSnapshot` (embedded clinic data at booking time)
- `inPersonDetails.locationVerified` (Boolean)

**SessionBooking (`sessionBooking.model.js`):**
- `consultationMode` (online | in_person, default: online, with 2 indexes)
- `arrivalStatus` (pending | arrived | no_show, default: pending)
- `arrivedAt` (Date)

**Setting (`setting.model.js`):**
- `inPersonConsultationEnabled` (Boolean, default: false)
- `inPersonSessionCommissionPercent` (Number)
- `inPersonClinicApprovalRequired` (Boolean)
- `inPersonLocationVerificationRequired` (Boolean)
- `inPersonShowContactBeforeBooking` (Boolean)
- `inPersonShowContactAfterBooking` (Boolean)
- `inPersonReminderMinutesBefore` (Number, default: 60)
- `inPersonNavigationEnabled` (Boolean)
- `inPersonCancellationTimeLimitMinutes` (Number, default: 120)
- `inPersonCancellationRefundPercent` (Number, default: 100)
- `inPersonCancellationRefundCredits` (Boolean)
- `inPersonCancellationRefundCreditsCount` (Number)
- `inPersonExpertCancellationPenaltyPercent` (Number, default: 10)

---

## Phase 2: Backend Changes ✅ COMPLETED

### Expert Controller (`expert.controller.js`)

| Function | Change | Description |
|---|---|---|
| `upsertExpertProfile` | Modified | Accepts `consultationModes`, `inPersonPricing`, `clinicDetails` in body. Validates and stores clinic details with coordinates. |
| `discoverExperts` | Modified | Accepts `consultationMode` query param. Filters by `consultationModes.inPerson` when mode=in_person. Checks clinic approval status when required. Returns consultationModes, inPersonPricing, clinicDetails. |
| `listAvailabilitySlots` | Modified | Accepts `consultationMode` query param. Filters availability by consultationMode. |
| `upsertAvailabilitySlots` | Modified | Accepts `consultationMode` per slot. Validates expert has in-person enabled before allowing in-person slots. |
| `getExpertClinic` | **New** | Returns expert clinic details. Respects contact visibility settings (`inPersonShowContactBeforeBooking`). |

### Session Controller (`session.controller.js`)

| Function | Change | Description |
|---|---|---|
| `createSession` | Modified | Accepts `consultationMode`. Uses in-person pricing when mode=in_person. Skips channel name for in-person. Snapshots clinic details into `inPersonDetails`. |
| `bookSession` | Modified | Accepts `consultationMode`. Validates in-person enabled globally. Uses in-person availability filter, pricing, and commission. Snapshots clinic details. |
| `getAvailableSlots` | Modified | Accepts `consultationMode` query param. Filters by consultationMode. Returns consultationMode in response. |
| `getBookingNavigation` | **New** | Returns Google Maps, Apple Maps, Waze navigation URLs for in-person bookings. |
| `markArrival` | **New** | Expert marks user as arrived. Updates `arrivalStatus` and `arrivedAt`. Sends push notification. |
| `markSessionCompleted` | **New** | Expert marks in-person session completed. Releases settlement, credits wallet, sends notification. |

### Admin Controller (`clinicManagement.controller.js` — NEW)

| Function | Description |
|---|---|
| `listClinics` | Lists all expert clinics with approval status. Supports filtering by status, search by name/city/state, pagination. Joins with User model for contact info. |
| `updateClinicApproval` | Approves or rejects a clinic. Sets `approvalStatus`, `approvedAt`, `approvedByAdminId`. Optional `rejectionReason`. |

### Commission Logic

```
if consultationMode === "in_person":
  if settings.inPersonSessionCommissionPercent is set and > 0:
    use inPersonSessionCommissionPercent
  else:
    use sessionCommissionPercent (shared with online)
else:
  use sessionCommissionPercent (existing)
```

### Pricing Logic

```
if consultationMode === "in_person":
  use expert.inPersonPricing.oneToOneSession
  currency = expert.inPersonPricing.currency
else:
  use expert.pricing.oneToOneVideo / oneToOneAudio / oneToOneSession (existing)
```

### API Endpoints — Modified

| Endpoint | Method | Change |
|---|---|---|
| `POST /experts/upsert-profile` | POST | Accept `consultationModes`, `inPersonPricing`, `clinicDetails` |
| `GET /experts/discover` | GET | Accept `consultationMode` filter |
| `GET /experts/availability/list` | GET | Accept `consultationMode` filter |
| `POST /experts/availability/upsert` | POST | Accept `consultationMode` per slot |
| `POST /sessions/create` | POST | Accept `consultationMode` |
| `POST /sessions/book` | POST | Accept `consultationMode` |
| `GET /sessions/available-slots` | GET | Accept `consultationMode` filter |

### API Endpoints — New

| Endpoint | Method | Purpose |
|---|---|---|
| `GET /experts/clinic/:expertId` | GET | Get expert clinic details |
| `GET /sessions/navigation/:bookingId` | GET | Get navigation URLs (Google Maps, Apple Maps, Waze) |
| `POST /sessions/:bookingId/arrive` | POST | Mark user arrival |
| `POST /sessions/:bookingId/complete` | POST | Mark session completed |
| `GET /admin/clinic/list` | GET | List all clinics (admin) |
| `PATCH /admin/clinic/approve` | PATCH | Approve/reject clinic (admin) |

---

## Phase 3: Admin Panel ✅ COMPLETED

### In-Person Settings Tab (`InPersonSettings.jsx`)

```
In-Person Consultation Settings
├── Enable In-Person Consultation (master toggle)
├── Pricing & Commission
│   └── In-Person Session Commission % (number, falls back to shared if empty)
├── Clinic Management
│   └── Require Admin Approval for Clinics (toggle)
├── Contact & Booking
│   └── Show Clinic Contact Before Booking (toggle)
├── Cancellation Policy
│   ├── Cancellation Time Limit (minutes before start)
│   ├── Late Cancellation Refund (%)
│   └── Expert Cancellation Penalty (max %)
└── Reminders & Navigation
    ├── Reminder Before Session (minutes)
    ├── Arrival Window (minutes after start)
    └── Enable Navigation to Clinic (toggle)
```

### Clinic Management View

- Paginated list of all expert clinics with approval status
- Filter by status: All / Pending / Approved / Rejected
- Search by clinic name, expert name, city, state
- Expandable rows showing full clinic details (address, contact, photos, instructions)
- Approve/Reject actions with rejection reason dialog
- Color-coded status chips (warning=pending, success=approved, error=rejected)

### Session Management

- Added "Mode" column with colored chip badges
- Online = blue chip, In-Person = purple chip

### Expert Management

- Added "Modes" column showing consultation mode badges
- Online badge when `consultationModes.online !== false`
- In-Person badge when `consultationModes.inPerson === true`

### Navigation & Permissions

- "Clinic Management" added to sidebar under User Management
- `clinicManagement` permission key added to moderator permissions
- Route permission mapping added for `/clinic-management`

---

## Phase 4: Mobile App (Flutter) ✅ COMPLETED

### Expert Profile Screen

```
Expert Profile
├── Online Badge (if consultationModes.online !== false)
├── In-Person Badge (if consultationModes.inPerson === true)
├── Clinic Name & City (green card, if clinicName is set)
├── In-Person Price tile (if inPersonPricing.oneToOneSession > 0)
├── About section (existing)
├── Pricing section (audio/video + in-person price)
├── Reviews section (existing)
├── [Chat Now] button (existing)
└── [Book Session] button (passes consultationModes + clinicDetails)
```

### Booking Flow

```
1. Mode Selection (if expert supports both modes)
   ├── [Online] chip → shows Audio/Video selection
   └── [In-Person] chip → shows clinic info card
2. Clinic Info Card (in-person mode)
   ├── Hospital icon + clinic name
   ├── Address (city, state, country)
   └── Consultation instructions
3. Date Selection (7-day horizontal scroll, same as before)
4. Slot Selection (grid, filtered by consultationMode)
5. Confirm Booking → passes consultationMode to bookSession API
```

### Discovery Screen (Home)

```
Home Screen
├── Spotlight Widget (existing)
├── Category Filter (existing horizontal scroll)
├── Consultation Mode Filter (NEW)
│   ├── All (default)
│   ├── Online (videocam icon)
│   └── In-Person (location icon)
└── Expert List (filtered by selected mode + category)
```

### Session List (My Sessions)

```
Session Card
├── Title + Status Badge (existing)
├── Expert Name (existing)
├── Meta Chips:
│   ├── Schedule (existing)
│   ├── Call Type (existing)
│   └── Consultation Mode (NEW: Online/In-Person)
├── Clinic Info Card (NEW, for in-person sessions)
│   ├── Hospital icon + clinic name
│   └── Address
├── [Navigate to Clinic] button (NEW, for in-person)
├── [Start Session] button (existing)
└── [Cancel Slot] button (existing)
```

---

## What's NOT Changed (Full Reuse)

| System | Reuse Status |
|---|---|
| Payment Gateway Processing | 100% Reused |
| Subscription/Credit System | 100% Reused |
| Wallet/Earnings System | 100% Reused |
| Refund Logic | Extended (mode-aware) |
| Cancellation Flow | Extended (mode-aware) |
| Notification Infrastructure | Extended (mode-aware) |
| Email Templates | Extended (mode-aware) |
| Push Notification System | 100% Reused |
| Socket.IO Events | 100% Reused |
| User Authentication | 100% Reused |
| Expert Verification | 100% Reused |
| Moderation System | 100% Reused |
| Feed System | 100% Reused |
| Recording System | Not applicable (in-person) |
| Group Sessions | Not applicable (in-person is 1:1 only) |

---

## Edge Cases Handled

| Edge Case | Handling |
|---|---|
| Expert enables in-person without clinic details | Block in-person bookings, prompt to complete profile |
| Expert disables in-person with active bookings | Existing bookings honored, no new in-person bookings |
| Expert moves clinic after bookings | Old bookings use snapshot; new bookings use updated details |
| Clinic approval pending | Block in-person bookings until approved (when `inPersonClinicApprovalRequired` = true) |
| Platform disables in-person globally | All in-person bookings blocked (`inPersonConsultationEnabled` = false) |
| Payment fails for in-person | Same retry/failure flow as online |
| Expert no-show for in-person | Same `callOutcomeStatus` flow |
| User no-show for in-person | Expert marks `arrivalStatus = "no_show"` |
| Overlapping online + in-person at same time | Prevented by existing overlap check |
| In-person session has no channel name | Channel name skipped for in-person (no video/audio call) |
| Expert has no in-person pricing set | Falls back to 0 or shared pricing |
| Expert in-person pricing currency mismatch | Uses expert's `inPersonPricing.currency` |

---

## Development Complexity

| Layer | Complexity | Estimated Effort | Status |
|---|---|---|---|
| Database Schemas | Low | 1-2 days | ✅ Done |
| Backend Controllers | High | 5-7 days | ✅ Done |
| Backend Routes | Low | 0.5 days | ✅ Done |
| Admin Panel | Medium | 5-7 days | ✅ Done |
| Mobile App | High | 7-10 days | ✅ Done |
| Testing | Medium | 3-5 days | ⏳ Pending |
| **Total** | | **22-32 days** | **~85% Complete** |

---

## Recommendations

1. **Test the online path unchanged** — Every modification must be verified to not break existing online booking flow.

2. **Feature-flag everything** — The `inPersonConsultationEnabled` setting acts as a master kill switch. All in-person code paths check this first.

3. **Snapshot clinic details** — Never reference live `ExpertProfile.clinicDetails` for a booked session — always snapshot at creation time.

4. **Clinic approval workflow** — When `inPersonClinicApprovalRequired` is enabled, experts must wait for admin approval before accepting in-person bookings.

5. **Geo queries performance** — The `clinicDetails.coordinates` 2dsphere index handles proximity searches. Monitor query performance with large datasets.

---

## Next Steps

1. [x] Phase 1: Database schema changes
2. [x] Phase 2: Backend controller and route changes
3. [x] Phase 3: Admin panel changes
4. [x] Phase 4: Mobile app (Flutter) changes
5. [ ] Unit tests for all modified backend logic
6. [ ] Integration tests for booking flow (online + in-person)
7. [ ] E2E testing on mobile (iOS + Android)
8. [ ] Edge case testing (all scenarios in Edge Cases table)
9. [ ] Performance testing for geo queries
10. [ ] Security audit
11. [ ] Documentation update (API docs, user guides)
12. [ ] Deployment plan (feature flag rollout)
