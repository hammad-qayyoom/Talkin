# Location Feature Roadmap (Notisboard)

This document is the implementation brief for adding the `nearest expert` location feature in the Flutter app.

Status: `Planned` (do not implement automatically; execute when requested)

## Goal

Show nearby experts to users based on device location, with clear permission handling and safe fallback behavior.

## Current Baseline (as of 2026-04-25)

- iOS `Info.plist` has camera/microphone/photo usage keys, but no location usage key.
- Android manifest has no `ACCESS_FINE_LOCATION` or `ACCESS_COARSE_LOCATION`.
- App privacy flow in App Store Connect is in progress.
- Existing code contains location/address fields in some models, but no end-to-end GPS permission + nearest-query flow.

## Scope for Future Implementation

1. Add platform permissions.
2. Add runtime permission + location fetch service.
3. Add backend/API contract for nearest experts query.
4. Integrate UI on user home/discovery flow.
5. Add fallback UX if permission denied/unavailable.
6. Update App Store privacy answers to match real behavior.
7. Verify with device testing (iOS + Android).

## Technical Plan

### 1) Dependencies

- Add `geolocator` for GPS coordinates.
- Optional: `geocoding` if we need reverse geocode text.

### 2) iOS Changes

- Add in `ios/Runner/Info.plist`:
  - `NSLocationWhenInUseUsageDescription`
- If background location is ever required later, add separate key only then (not in first release).

### 3) Android Changes

- Add in `android/app/src/main/AndroidManifest.xml`:
  - `android.permission.ACCESS_COARSE_LOCATION`
  - `android.permission.ACCESS_FINE_LOCATION`
- Keep request `while in use` behavior only.

### 4) Flutter Service Layer

Create a reusable service, for example:

- `lib/services/location/location_service.dart`

Responsibilities:

- check if location service enabled
- request permission safely
- fetch current lat/lng with timeout
- return typed result states:
  - success
  - denied
  - deniedForever
  - serviceDisabled
  - timeout/error

### 5) API Contract

Add/update endpoint usage for nearest experts:

- request params (expected):
  - `latitude`
  - `longitude`
  - optional radius
  - pagination

Notes:

- confirm backend sorting by distance
- confirm unit (`km` or `miles`)
- include distance in response for UI display

### 6) UI Integration

Candidate screens:

- user home listener/expert list
- search/discovery listing

Behavior:

- first app visit: ask location permission when user opens nearby section
- if granted: fetch nearest list
- if denied: show non-blocking fallback list + CTA `Enable Location`
- if denied forever: show button to open settings

### 7) App Store Privacy Mapping (when feature is live)

For App Store Connect `Data Collection`:

- `Precise Location`: collected
- Linked to user identity: `Yes`
- Tracking: `No` (unless ad tracking is introduced)
- Data use:
  - `App Functionality`
  - `Product Personalization` (if ranking/recommendation uses location)

## Acceptance Criteria

- User can grant location permission and see nearest experts sorted by distance.
- Permission denied flow does not block app usage.
- Permission denied forever flow has `Open Settings` action.
- No crash when GPS unavailable or timeout occurs.
- iOS and Android both tested on physical devices.
- App Store privacy fields match implemented behavior.

## Testing Checklist

- [ ] iOS fresh install: permission allow -> nearest list loads
- [ ] iOS deny once -> fallback list shown
- [ ] iOS deny forever -> settings flow works
- [ ] Android allow -> nearest list loads
- [ ] Android deny -> fallback list shown
- [ ] Airplane mode / no network handling
- [ ] API timeout handling
- [ ] Distance rendering and pagination validated

## Rollout Notes

- Keep feature behind a toggle if backend readiness is uncertain.
- Release in phased rollout if possible.

## Execution Trigger

When you want implementation to start, use this instruction:

`Implement LOCATION_FEATURE_ROADMAP.md end-to-end now`

