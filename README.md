# Verra: AI-powered e-commerce app (Flutter, Material 3)

## Run it
This archive contains `lib/`, `pubspec.yaml` and docs. Generate the Android scaffolding once, then run:

```bash
flutter create . --platforms=android --project-name verra
flutter pub get
flutter run
```

Add to `android/app/src/main/AndroidManifest.xml` (needed for the 3D viewer and network images in release builds):
```xml
<uses-permission android:name="android.permission.INTERNET"/>
```
Set `minSdkVersion` to 21 or higher in `android/app/build.gradle`. For gallery upload, `image_picker` needs no extra setup on Android.

Demo logins: any email with a 6+ character password. Admin: Profile > Admin dashboard, `admin@verra.app` / `admin123`.

## Structure
```
lib/
  main.dart                  app entry, theme mode
  core/        theme.dart (tokens, M3 theme), utils.dart (formatting, routes, snackbar)
  models/      Product, Category, CartItem, Order, Address, AppUser
  data/        mock_data.dart (swap for backend)
  state/       app_state.dart (Provider ChangeNotifier: auth, catalogue, cart, wishlist, orders, admin)
  services/    ai_search_service.dart (intent parser), voice_service.dart (mock, swappable)
  widgets/     ProductCard, ProductImage, ProductGrid, AppSearchField, EmptyState, SectionHeader
  screens/     splash, onboarding, auth/, shell, home, categories, product_list, search,
               voice_search, product_detail, viewer_3d, cart, checkout, wishlist, profile, admin/
```

## Backend and AI hooks
- **Backend:** replace the lists in `AppState` with repository calls; screens only talk to `AppState`.
- **Semantic search:** implement the same `SearchOutcome` contract in `AiSearchService.search` using an embeddings or LLM endpoint.
- **Voice:** implement `VoiceService` with `speech_to_text` and add the `RECORD_AUDIO` permission. The UI is already wired for partial results.
- **3D:** set `Product.modelUrl` to any `.glb`/`.gltf`. The demo points at a sample model.
- **Images:** products with no image show a category-tinted placeholder. Admin uploads store a local file path, so upload to storage and save the URL once you have a backend.
- **Admin auth:** the demo password check is client-side only. Replace with a server-verified role.
