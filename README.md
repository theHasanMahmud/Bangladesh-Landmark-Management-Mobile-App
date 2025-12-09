# Bangladesh Landmarks App

Flutter mobile app for the CSE489 assignment that manages Bangladesh landmarks via the provided REST API (`https://labs.anontech.info/cse489/t3/api.php`).

## Features
- Auth gate with a simple token to protect CRUD calls.
- Bottom navigation: map overview, records list, and new entry form.
- Map clustering, style switcher, and locate-me control.
- Swipeable list items for edit/delete with cached thumbnails.
- Create/update form with GPS autofill and 800x600 image resize (mobile), plus offline cache on mobile.

## Running
- Install Flutter 3.x
- `flutter pub get`
- `flutter run` (choose Android/iOS/web as needed)

For web builds, file uploads are skipped; test full image flows on mobile.
