# Bangladesh Landmarks – REST-backed CRUD app

Flutter app for CSE489 that manages Bangladesh landmarks against the provided API (`https://labs.anontech.info/cse489/t3/api.php`). Auth is powered by Clerk, UI is Cupertino-styled, and data is cached offline with SQLite.

![Flutter](https://img.shields.io/badge/Flutter-3.13+-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.2+-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Cupertino](https://img.shields.io/badge/Design-Cupertino-5856D6?style=for-the-badge)

---

## Preview
Map overview, records list with swipe actions, and a form for add/edit. (Screenshots/GIFs can be dropped here.)

---

## Key Features

### Authentication
- Clerk Flutter SDK with Cupertino login UI.
- Session token bridged into API calls (Bearer).
- One-tap sign-out from the nav bar.

### Map Overview
- Centered on Bangladesh with custom OSM tiles (standard/terrain/light).
- Marker clustering; tap marker opens a bottom sheet with title, image preview, and edit/delete quick actions.
- Locate-me control recenters on current GPS; snackbar feedback and dialogs on errors.

### Records List
- Recycler list of cards with title, lat/lon preview, thumbnail.
- Swipe left/right for delete/edit; pull-to-refresh.
- Newest records first (sorted by ID).

### Landmark Form
- Fields: title, latitude, longitude, image picker.
- Auto-fill current GPS on add; images resized to 800×600 before upload.
- Uses multipart POST/PUT to the provided REST API.

### Offline & Caching
- SQLite (sqflite) cache of fetched landmarks for offline viewing.
- Shared prefs for auth token persistence.
- Graceful fallback to cached data if network fails.

---

## Application Requirements Coverage

### Navigation & Layout
- Bottom navigation with three tabs: **Overview** (map), **Records** (list), **New Entry** (form). Drawer removed in favor of tabs.

### Map-Based Display
- Map centers on Bangladesh (23.6850°N, 90.3563°E).
- Custom OSM markers with clustering.
- Marker tap opens a bottom sheet showing title, image preview, and quick edit/delete actions.

### List-Based Display
- Recycler-style list of cards with title, short location info, and thumbnail.
- Swipe left/right triggers edit/delete actions.

### Landmark Form
- Separate screen for add/edit with fields: title, latitude, longitude, image selector.
- Auto-detects current GPS for new entries.
- Images resized to 800×600 before submission.

### Error & Feedback Handling
- Snackbars confirm success (create/update/delete, sign-out).
- Dialogs surface errors (network, location permissions, delete failures).

### Map Technology
- Uses OpenStreetMap via `flutter_map` with selectable styles (standard/terrain/light) for differentiation.

---

## Tech Stack

- **Framework:** Flutter (Cupertino + Material under the hood)
- **Language:** Dart 3
- **Packages:** `clerk_flutter`, `flutter_map`, `geolocator`, `sqflite`, `image_picker`, `cached_network_image`, `flutter_slidable`, `http`
- **API:** `POST/GET/PUT/DELETE https://labs.anontech.info/cse489/t3/api.php`

---

## Project Structure

```
Bangladesh-Landmark-Management-Mobile-App/
├── lib/
│   ├── main.dart            # App entry, Cupertino shell, auth gate
│   ├── screens/             # Map, list, form, login
│   ├── services/            # API, auth, DB helpers
│   ├── models/              # Landmark model
│   └── widgets/             # Cards, helpers
├── android/ ios/ web/ macos/ linux/ windows/
├── pubspec.yaml
└── README.md
```

---

## Getting Started

### Prerequisites
- Flutter SDK 3.13+ (`flutter --version`)
- Dart SDK (bundled with Flutter)
- Android emulator or iOS simulator/device

### Installation
```bash
git clone https://github.com/theHasanMahmud/Bangladesh-Landmark-Management-Mobile-App.git
cd Bangladesh-Landmark-Management-Mobile-App
flutter pub get
```

### Run
```bash
flutter run \
  --dart-define=CLERK_PUBLISHABLE_KEY=pk_test_c3VtbWFyeS1lZnQtMTkuY2xlcmsuYWNjb3VudHMuZGV2JA
```
Select your device (e.g., `emulator-5554`). For web, note that file uploads are limited; test full image flows on mobile.

---

## API Notes
- **Create (POST /api.php):** `title`, `lat`, `lon`, `image` (multipart)
- **Read (GET /api.php):** returns array of `{id,title,lat,lon,image}`
- **Update (PUT /api.php):** `id`, `title`, `lat`, `lon`, optional `image`
- **Delete (DELETE /api.php):** `id`

---

## Testing & Quality

```bash
flutter analyze
flutter test   # (add/extend tests as needed)
```
Manual checks: login flow, add/edit/delete, map markers + bottom sheet actions, GPS autofill, offline cache fallback, swipe actions in list.

---

## Roadmap
1) Add screenshot/GIF gallery.  
2) Strengthen widget tests for CRUD flows.  
3) Localization (Bangla/English).  
4) Theming polish for map markers and cards.

---

## Contact

Questions or feedback? Reach out at `hasanmahmudmajumder@gmail.com`. If this helped, star the repo.။
