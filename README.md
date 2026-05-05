# Baringo Staff Performance Mapping

A Flutter + Firebase application used by **Baringo County Government, Kenya** to
track staff field activities, validate field visits with GPS coordinates, and
generate performance reports.

**Live demo:** [https://bcg-staff-app.web.app](https://bcg-staff-app.web.app)

---

## Features

- **Authentication** with Firebase Auth (email + password, password reset).
- **Role-based UI** — separate dashboards for staff and administrators. Admin
  status is gated server-side via Firestore security rules.
- **Department-aware reporting** — Agriculture, Health, Water, Devolution, and
  a generic fallback all share a common form scaffold and capture
  department-specific fields.
- **Field-visit verification** with GPS (`geolocator`) and best-effort IP
  geolocation.
- **Photo capture** uploaded to Firebase Storage and linked to the report.
- **Admin dashboard** — paginated users / tasks tabs, department + date-range
  filters, on-device PDF export of the filtered view.
- **Map view** of any report location via `google_maps_flutter`.

## County coverage

The reference data in `lib/constants/baringo_data.dart` covers all 7
sub-counties and 30 wards of Baringo County (IEBC ward boundaries) and the
current departmental structure of the County Government:

- Baringo Central, Baringo North, Baringo South, Mogotio, Eldama Ravine,
  Tiaty East, Tiaty West.

## Tech stack

- **Frontend:** Flutter (Material 3, Provider for state).
- **Auth:** Firebase Authentication.
- **Database:** Cloud Firestore.
- **Storage:** Firebase Storage (report photos).
- **Maps:** Google Maps Flutter.
- **Hosting:** Firebase Hosting (`firebase deploy --only hosting`).

## Requirements

- Flutter SDK ≥ 3.22, Dart ≥ 3.4.
- A Firebase project with Authentication, Firestore, and Storage enabled.
- A Google Maps API key (Android: meta-data in `AndroidManifest.xml`,
  iOS: `AppDelegate`).

## Getting started

The project deliberately gitignores Firebase config (`.firebaserc`,
`lib/firebase_options.dart`, `android/app/google-services.json`, iOS / macOS
plists) and any signing keys / `.env` files. Generate them locally:

```bash
git clone https://github.com/Chebon-breezy/baringo-staff-monitor.git
cd baringo-staff-monitor
flutter pub get

# Project alias — copy the template and put your project ID in
cp .firebaserc.example .firebaserc

# FlutterFire writes lib/firebase_options.dart and the platform service files
dart pub global activate flutterfire_cli
flutterfire configure

# Drop in your Google Maps API key
#   android/app/src/main/AndroidManifest.xml  →  com.google.android.geo.API_KEY
#   ios/Runner/AppDelegate.swift              →  GMSServices.provideAPIKey(...)

flutter run
```

> **Heads up:** Firebase client API keys (in `firebase_options.dart`,
> `google-services.json`, etc.) are designed to be embedded in client builds.
> They identify the app, not authenticate it — security is enforced by
> Firestore security rules, App Check, and API-key restrictions in the Google
> Cloud Console. Earlier versions of this repository tracked those files; if
> you need them rotated, regenerate the FlutterFire output and restrict the
> keys in GCP.

Deploy security rules and indexes:

```bash
firebase deploy --only firestore:rules,firestore:indexes
```

## Project layout

```
lib/
  constants/        Baringo county data + theme.
  models/           UserModel, WorkReportModel.
  providers/        AuthProvider (ChangeNotifier).
  services/         Auth / Firestore / Storage / Location wrappers.
  screens/
    auth/           Login, register, department selection.
    user/           Home, profile, report router + report screens.
    admin/          Dashboard, user details, map view.
  widgets/          CustomButton, CustomTextField.
```

## Testing

```bash
flutter test
flutter analyze
```

## Contributing

Pull requests welcome. Please run `flutter analyze` before opening a PR.

## Contact

Brian Chebon — brianlchebon@gmail.com
