# SproutRoll: Jungle Glow Edition

A gamified plant-care MVP built with Flutter. Roll themed "dice" to get
bite-sized plant quests, snap a photo for a mock AI diagnosis, earn coins,
and spend them in the Reward Store — all wrapped in a cyber-organic
jungle-glow glassmorphism theme.

## Stack

- Flutter (Android-focused, cross-platform capable)
- `provider` for state management (single `AppState` ChangeNotifier)
- `sensors_plus` for shake-to-roll detection
- `image_picker` for the AI Plant Doctor photo capture
- All animations (splash sprout, dice tumble, confetti burst, laser scan)
  are hand-built with `AnimationController` / `CustomPainter` — no Lottie
  or external animation assets required

## Project layout

```
lib/
  main.dart                  # App entry point, theme + Provider wiring
  theme/                     # Color palette + ThemeData
  models/                    # Quest, QuestType, CompletedQuest, StoreItem
  data/                      # Static mock content banks (quests, store, diagnoses)
  providers/app_state.dart   # Coins, scan credits, skins, Pro status, history
  widgets/                   # GlassCard, GlowButton, ModeCard, CustomPainters
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
  (including the `provider`, `sensors_plus`, and `image_picker` plugin
  code) with zero errors, and the resulting binary was launched headlessly
  (Xvfb) and confirmed to render the Home screen correctly with live state
  (coin balance, mode cards, bottom nav).

The `lib/` code itself is platform-agnostic Flutter/Dart and targets
Android through the scaffold above.

## Mock/local-only state

There is no backend. `AppState` (see `lib/providers/app_state.dart`) keeps
everything in memory for the session:

- Coins (start at 100)
- Daily AI Doctor scan credits (start at 2, unlimited if "Pro")
- Owned/equipped dice skins + consumable inventory (e.g. Streak Freeze Shield)
- Pro status (mocked purchase from the paywall)
- Full quest history (claimed + forfeited) for the Garden Log

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
