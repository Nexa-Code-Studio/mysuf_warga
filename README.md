# MySuF Mobile (Frontend)

MySuF (Smart Subsidized Fuel Ecosystem) is a Flutter frontend for citizen-facing services such as quota monitoring, wallet, transaction history, and vehicle/family linking. This repository focuses on UI only and uses mock/local data for now.

## Tech Stack

- Flutter
- Riverpod
- Go Router
- Dio (reserved for API integration)
- Shared Preferences
- Flutter Secure Storage
- Flutter ScreenUtil
- Flutter SVG
- Google Fonts
- Flutter Animate

## Project Structure

```
lib/
	core/
	features/
	routes/
	shared/
```

Each feature follows clean architecture:

```
features/<feature_name>/
	data/
	domain/
	presentation/
```

## Setup

1. Install Flutter (3.22+ recommended).
2. Get packages:

```
flutter pub get
```

3. Run the app:

```
flutter run
```

## Notes

- This project is UI-only. Backend/API integration will be added later.
- All data is currently mocked in `lib/core/services/mock_api.dart`.
- Navigation uses Go Router with a 5-tab bottom navigation layout.

## Next Steps

- Connect API endpoints with Dio.
- Add real authentication and secure storage flows.
- Expand models and validation rules for production.
