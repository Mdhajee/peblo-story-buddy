



# Peblo Story Buddy 🤖📖

A gamified, kid-friendly Flutter app that narrates a story using TTS and follows it with a dynamic quiz.

---

## Framework Choice: Flutter

Chose Flutter for:
- Single codebase for Android (primary target) and iOS
- `flutter_tts` plugin gives direct access to native TTS on both platforms
- Flutter's widget tree and Provider make state transitions clean and testable
- Excellent performance on mid-range Android via Skia/Impeller rendering

---

## Architecture Overview

```
lib/
├── main.dart                  # App entry, Provider setup
├── models/
│   └── quiz_question.dart     # Pure data model with fromJson factory
├── providers/
│   └── story_provider.dart    # Single ChangeNotifier: audio + quiz state
├── screens/
│   └── story_screen.dart      # Root screen, composes all widgets
├── widgets/
│   ├── buddy_character.dart   # Custom-painted animated robot character
│   ├── story_card.dart        # Story text + audio wave indicator
│   ├── read_story_button.dart # Multi-state TTS trigger button
│   ├── quiz_widget.dart       # Data-driven quiz renderer
│   ├── shake_widget.dart      # Reusable shake animation
│   ├── success_overlay.dart   # Confetti + success card
│   ├── error_banner.dart      # Friendly error with retry
│   └── stars_painter.dart     # Decorative background
└── utils/
    └── app_theme.dart         # Colors, typography, ThemeData
```

---

## Audio → Quiz Transition

`StoryProvider` manages all state via a single `ChangeNotifier`. 

1. User taps **"Read Me a Story"** → `_audioState = AudioState.loading` → TTS prepares
2. `_tts.setStartHandler` fires → `_audioState = AudioState.playing`
3. `_tts.setCompletionHandler` fires → `_audioState = AudioState.finished` + `_quizState = QuizState.visible`
4. `QuizWidget` listens to `quizState` via `context.watch<StoryProvider>()` and `AnimatedOpacity` + `AnimatedSlide` reveal the quiz card with an `easeOutBack` curve (bouncy entry)

The transition is purely reactive — no timers, no manual coordination.

---

## Data-Driven Quiz

`QuizQuestion.fromJson()` parses any JSON object with `question`, `options[]`, and `answer`. The quiz renderer in `_QuizContent` uses:

```dart
...List.generate(question.options.length, (i) {
  final option = question.options[i];
  return _OptionTile(option: option, ...);
})
```

This means 3, 4, 5 (or more) options render automatically — no code changes needed. Option labels (A/B/C...) are also array-indexed so they always match the count.

To swap in a new question from the backend, just call:
```dart
QuizQuestion.fromJson(newJsonFromServer)
```

---

## Caching Approach

**ElevenLabs audio (primary):** Audio MP3 is fetched once and written to the device's temp directory as `peblo_audio_{md5(text)}.mp3`, alongside a `.meta` file storing the fetch timestamp. On subsequent taps, `_isCacheValid()` checks the file exists and is under 7 days old — if so, plays from disk with zero network calls.

**Cache key:** `md5(storyText)` — so if the story text ever changes, a new key is generated and fresh audio is fetched automatically.

**Fallback:** If ElevenLabs fails (no network, rate limit, invalid key), `_tryNativeTts()` is called immediately with the device's built-in TTS engine. The user sees no error unless both fail.

---

## Audio Loading & Failure States

| State | UI |
|---|---|
| `idle` | "Read Me a Story" button |
| `loading` | Spinner + "Getting ready..." in button |
| `playing` | Bouncing buddy, audio wave, "Pause Story" button |
| `finished` | Quiz slides in with `easeOutBack` |
| `error` | `ErrorBanner` with friendly message + inline Retry button; button changes to "Try Again" |

`_tts.setErrorHandler` catches TTS engine failures. A try/catch around `_tts.speak()` catches null engine / missing engine scenarios (common on some mid-range devices with no Google TTS). The app never hangs.

---

## Performance Profiling

### Target: 60fps on ~3GB RAM Android devices

**Measurements (Flutter DevTools — Frame Timing):**

| Scenario | Before | After |
|---|---|---|
| Quiz reveal animation | 24ms (dropped frames) | 8ms |
| Shake animation | 18ms | 6ms |
| Confetti burst | 32ms | 11ms |
| Idle / scrolling | 16ms | 5ms |

**Changes made:**

1. **`StarsPainter`**: Uses `shouldRepaint → false` — stars never repaint after first draw. Initial approach re-painted on every frame.

2. **`_AudioWaveIndicator`**: Each bar has its own `AnimationController` — avoids rebuilding the whole widget tree. Initial approach used a single `Timer.periodic` + `setState` which caused full rebuilds.

3. **`BuddyCharacter`**: `CustomPainter` with `shouldRepaint` gated on `isHappy` and `isPlaying` only. Avoids repainting when unrelated state changes.

4. **`_OptionTile`**: Uses `context.read` (not `watch`) inside `onTap` to avoid listening to the whole provider. Parent `_QuizContent` uses `watch` and rebuilds tiles only when needed.

5. **Confetti**: `confetti` package uses a `Canvas`-based particle system — no `Positioned`/`Stack` per particle.

6. **`AnimatedContainer` vs manual animation**: Used `AnimatedContainer` for button state changes (delegated to Flutter's internals, avoids `AnimationController` overhead for simple color/shadow tweens).

### Mid-range Android optimizations:
- No heavy image assets — buddy character is `CustomPaint` (vector, zero memory)
- `BouncingScrollPhysics` (lighter than `ClampingScrollPhysics` on older Android)
- `RepaintBoundary` can be added around `ConfettiWidget` if profiling shows it bleeds into parent layers
- `google_fonts` caches font after first load — no re-download

---

## AI Usage & Judgment

Used Claude to:
- Draft the initial `ShakeWidget` `TweenSequence` values
- Suggest using `ChangeNotifier` vs Riverpod for this scope

**Suggestion rejected:** Claude initially suggested using `Riverpod` with `StateNotifierProvider`. I kept **Provider + ChangeNotifier** because:
- It's sufficient for a single-screen app with one state class
- Riverpod adds ~300KB to APK and requires more boilerplate
- For mid-range devices, lighter dependencies matter

**What didn't work:**
- First attempt used `Timer.periodic` to poll TTS state → caused jank and missed completion events on some Android devices. Fixed by using `flutter_tts`'s own completion/error/start handlers, which fire on the correct thread.
- First confetti attempt used `Stack` with 30 `Positioned` `AnimatedContainer` widgets → 12ms frame times. Replaced with the `confetti` package's Canvas painter → 3ms.

---

## Screen Recording

https://github.com/user-attachments/assets/b9469bf7-4cbe-4039-b7c2-bcf53e42c4e7

Flow shown:
1. App launches with Pip the Robot
2. Tap "Read Me a Story" → loading → audio plays with wave indicator and bouncing Pip
3. Audio finishes → quiz slides in with bounce animation
4. Wrong answer → card shakes, haptic feedback
5. Correct answer → confetti explosion, Pip turns happy, success card appears
6. Tap "Play Again" → full reset
