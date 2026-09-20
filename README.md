# SproutRoll: Jungle Glow Edition

A gamified plant-care MVP built with Flutter. Roll themed "dice" to get
bite-sized plant quests, snap a photo for a real Gemini-powered diagnosis,
chat with an AI plant-care assistant, earn coins, and spend them in the
Reward Store — all wrapped in a cyber-organic jungle-glow glassmorphism
theme.

## Stack

- Flutter (Android-focused, cross-platform capable)
- `provider` for state management (single `AppState` ChangeNotifier)
- `sensors_plus` for shake-to-roll detection
- `image_picker` for the AI Plant Doctor photo capture
- `http` for calling the Gemini API directly from the client
- `flutter_secure_storage` for persisting user-supplied Gemini API keys
  (Android Keystore-backed)
- All animations (splash sprout, dice tumble, confetti burst, laser scan)
  are hand-built with `AnimationController` / `CustomPainter` — no Lottie
  or external animation assets required

## AI features (bring your own Gemini API key)

Settings (gear icon, top-right of Home) has a **Gemini API Keys** section:
paste in one or more keys from [Google AI Studio](https://aistudio.google.com/apikey)
and tap "Add API Key". Every AI surface in the app shares this key pool:

- **AI Plant Doctor** (`quest_result_screen.dart`) sends the captured photo
  to `gemini-2.0-flash` for a real one-line diagnosis + care instruction.
- **AI Chat** (`chat_screen.dart`) is a free-form conversation with a
  plant-care assistant persona.
- **Automatic fallback**: `GeminiService` (`lib/services/gemini_service.dart`)
  tries the active key first; if a call fails (quota exhausted, invalid
  key, etc.) it automatically retries with the next key in the list and
  remembers which one worked, so future requests start there directly.
- **Graceful degradation**: with no keys configured, AI Doctor falls back
  to a canned demo diagnosis and AI Chat prompts the user to add a key —
  the app is never blocked on having a key.

No key ever leaves the device except in the direct HTTPS request to
`generativelanguage.googleapis.com` — there's no backend relay.

## Project layout

```
lib/
  main.dart                  # App entry point, theme + Provider wiring
  theme/                     # Color palette + ThemeData
  models/                    # Quest, QuestType, CompletedQuest, StoreItem
  data/                      # Static mock content banks (quests, store, diagnoses)
  providers/app_state.dart   # Coins, scan credits, skins, Pro status, history
  widgets/                   # GlassCard, GlowButton, ModeCard, CustomPainters
  services/gemini_service.dart # Gemini REST client with API-key fallback
  screens/
    splash_screen.dart           # Screen 1: Magical Awakening
    home_shell.dart               # Screen 2 shell: bottom nav
    roll_home_tab.dart            # Screen 2 content: top bar + mode grid
    rolling_arena_screen.dart     # Screen 3: dice tumble + shake-to-roll
    quest_result_screen.dart      # Screen 4: quest card + AI Doctor flow
    reward_popup_screen.dart      # Screen 5: Botanical Win popup
    paywall_screen.dart           # Screen 6: Pro upgrade paywall
    reward_store_screen.dart      # Screen 7: Reward Store
    garden_log_screen.dart        # My Garden Log tab
    settings_screen.dart          # Settings: account + Gemini API key pool
    chat_screen.dart              # AI Chat with the plant-care assistant
```

## Running

```bash
flutter pub get
flutter run            # launches on a connected Android device/emulator
```

To build a release APK:

```bash
flutter build apk --release
```

> Note: the `android/` folder here is a hand-authored minimal scaffold
> (Groovy Gradle, Kotlin `MainActivity`, vector launcher icon). If your
> local Flutter SDK version expects a different Gradle/AGP/Kotlin
> combination, run `flutter create .` in the project root once to let
> Flutter regenerate `android/` for your toolchain, then re-apply `lib/`
> and `pubspec.yaml` from this repo (they don't depend on the Android
> scaffold version).

## Verified

No Android SDK/emulator was available in the environment this was built
in, so the Android build itself couldn't be exercised directly. Instead,
correctness was verified with the real Flutter 3.24.5 SDK:

- `flutter pub get` resolves all dependencies cleanly.
- `flutter analyze` reports **no issues**.
- `flutter test` passes (splash screen smoke test).
- `flutter build linux --debug` compiles and links the entire app
  (including `provider`, `sensors_plus`, `image_picker`, `http`, and
  `flutter_secure_storage`) with zero errors, and the resulting binary was
  launched headlessly (Xvfb) and driven end-to-end: Home → rolling a
  quest → claiming it (coin balance updates live in the Store and Garden
  Log) → Settings → adding a Gemini API key (masked, shown "Active") →
  opening AI Chat (correctly switches from the "add a key" prompt to the
  live chat UI once a key exists).
- `AppState.init()` is defensive about secure storage: a locked/unavailable
  keyring (hit during Linux-desktop testing here) is caught and logged
  instead of crashing app startup, degrading to "no saved keys".

The `lib/` code itself is platform-agnostic Flutter/Dart and targets
Android through the scaffold above.

## Mock/local-only state

There is no backend of our own. `AppState` (see `lib/providers/app_state.dart`)
keeps most state in memory for the session:

- Coins (start at 100)
- Daily AI Doctor scan credits (start at 2, unlimited if "Pro")
- Owned/equipped dice skins + consumable inventory (e.g. Streak Freeze Shield)
- Pro status (mocked purchase from the paywall)
- Full quest history (claimed + forfeited) for the Garden Log

The one exception is **Gemini API keys**, which are persisted via
`flutter_secure_storage` (Android Keystore) so they survive app restarts —
losing them every launch would defeat the point of adding your own key.

## Design tokens

| Token | Hex |
|---|---|
| Background | `#121614` |
| Surface (card) | `#1E2D24` |
| Neon Mint (accent) | `#25E289` |
| Amber Gold (coins) | `#E9C46A` |
| Soft Sage (secondary text) | `#74C69D` |

Cards use a 16px border radius, a `#25E289` border at 20% opacity, and a
glow `BoxShadow` with `blurRadius: 12` — see `lib/widgets/glass_card.dart`.
