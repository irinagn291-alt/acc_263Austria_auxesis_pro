# Auxesis — Build Specification

> Portfolio app 132, batch pending. This document is the complete brief for
> building this application. Read all of it before writing any code. Anything
> not specified here is your decision, but must stay consistent with section 3.

**One-line positioning:** Breathe longer each round and watch the rings grow.

| Field | Value |
| --- | --- |
| Product name | Auxesis |
| Bundle identifier | `com.auxesis.ring` |
| Domain | https://auxesis-ring.pro |
| Contact URL | https://auxesis-ring.pro/contact-us |
| Deployment target | iOS 17.0 |
| Swift version | 6.2, strict concurrency `complete` |
| Devices | iPhone and iPad, portrait |
| Interface style | Dark |
| Asset prefix | `aux_` |
| User-Agent | `Auxesis/1.0 (iOS; +https://auxesis-ring.pro)` |

---

## 1. Non-negotiable constraints

1. **No CocoaPods.** Dependencies come from Swift Package Manager, a local
   in-repo package, a vendored source folder, or nothing at all — per section 3.
2. **No shared code with other portfolio apps.** Business rules are re-implemented
   here under this app's own type names.
3. **All code, identifiers, comments, UI copy and the README are in English.**
4. **No launch gate, no WebView shell, no remote configuration, no analytics.**
   Guideline 4.2 (Minimum Functionality): this is a native SwiftUI product, not
   a web browsing experience. WKWebView / SFSafariViewController as UI is a
   reject. Push notifications, Core Location, and sharing do not make a
   browser or a thin catalog into an App Store app.
5. **Guideline 5.1.1 (Privacy):** never direct the user to grant camera access.
   A pre-permission screen may exist; the proceed button is **Continue** or
   **Next**, never "Allow camera", "Enable camera", "Grant camera", or a bare
   Allow/Enable that triggers `requestAccess`. The system alert is the only Allow.
6. **No CI files.** No `bitrise.yml`, no `Scripts/`, no `metadata/` folder.
7. **Assets are AI-generated.** No stock photography. SF Symbols may support
   small affordances but must never be the primary iconography.
8. **The app must build clean** with
   `xcodegen generate && xcodebuild -scheme Auxesis -destination 'generic/platform=iOS' build`.
9. **Nothing may echo another app in this batch** in naming, layout or visuals.
10. **This is not a calorie meal-slot tracker** unless family is `food_tracker`.
   Do not invent food logging to fill the brief.

---

## 2. Product core

The product is offline-first. No account, no sign-in, no ads, no in-app purchase,
no analytics SDK, no remote config. All user data stays on the device.

A breather long-presses the circle to feel the pace then swipes a duration so the guided round files as one ring on today's ascending canvas.

### 2.1 User flow

1. Launch opens the Canvas showing today's ring stack; seed already placed one thin Ring so the circle pulses ready.
2. Long-press the center circle; haptic pulses mark the inhale-exhale pace the longer you hold.
3. Swipe up to set the round duration; the span must equal or exceed the outermost ring or haptics refuse.
4. Release: the guided cycle begins; the ring grows on inhale, holds, and shrinks on exhale at the held pace.
5. Completing the final exhale writes a RingLayer; the new ring appears on the canvas from center outward.
6. Completing the seventh ring seals the canvas with a FullMark; the day is done and read-only.
7. Tapping Practices opens a sheet listing sealed and partial canvases by day.
8. Tapping Stats shows total rings, full-day count, and consecutive-day streak.

### 2.2 Essential behaviour

- Long-press circle sets the inhale-exhale pace via haptic feedback; the user's own rhythm becomes the guide.
- Swipe gesture sets round duration with ascending enforcement; shorter than the outermost ring is refused.
- Guided breath cycle with visual ring growth: expand on inhale, hold, shrink on exhale.
- Day-keyed canvas accumulates up to seven ascending rings from center outward.
- FullMark seals a completed seven-ring canvas as read-only.
- Practices sheet lists historical canvases with sealed and partial status.
- Stats tracks total rings, full-day count, and consecutive-day streak.
- Seed places one thin ring so the first swipe can ascend immediately.

---

## 3. Uniqueness assignment for Auxesis

| Axis | Assigned value |
| --- | --- |
| Architecture | **Phase-ring accumulation (Idle | Pacing | Guided); the canvas is a fold over Rings per daykey; Press writes a Pace from the held haptic interval and folds Idle to Pacing; Swipe writes a Duration and folds Pacing to Guided; completing the final exhale writes a RingLayer and folds Guided to Idle; abandoning mid-cycle resets to Idle without a layer; Swipe on Idle is refused; a second Press while Guided is refused; the seventh RingLayer writes a FullMark and seals the Canvas; empty canvas writes Clear** |
| UI approach | **Programmatic UIKit · realitykit-lite** |
| Naming convention | **Auxesis / crescendo-ring lexicon** |
| File organization | **By ring role (Canvas, Ring, Pace, RingLayer, FullMark, AbandonMark, Clear)** |
| Dependency strategy | **Modular local SPM** |
| Design direction | **kraken · bento · mid** |
| Typography | **SF Pro Rounded** |
| Navigation pattern | **Canvas-locked chrome (the canvas never leaves; Practices and Stats arrive as sheets; press and swipe fuse on Canvas) · 62a5080630** |
| AI art style | **Flat corporate vector data viz · mixed-media** |
| Functional twist | **Ascending-ring strata (each Ring must equal or exceed the prior Ring's Duration; seven Rings seal the Canvas; a shorter swipe is refused; seed places one thin Ring)** |
| Persistence | **Core Data+FRC** |
| Screen composition | see 3.6 |

### 3.0 Product concept

This is the product the contracts below are assigned to. Do not substitute another.

**Family** — breath_canvas

**Core** — A breather long-presses the circle to feel the pace then swipes a duration so the guided round files as one ring on today's ascending canvas.

**Audience** — A daily breather who wants a visible crescendo: each round must last at least as long as the last, and seven rings seal the day.

**User flow**

1. Launch opens the Canvas showing today's ring stack; seed already placed one thin Ring so the circle pulses ready.
2. Long-press the center circle; haptic pulses mark the inhale-exhale pace the longer you hold.
3. Swipe up to set the round duration; the span must equal or exceed the outermost ring or haptics refuse.
4. Release: the guided cycle begins; the ring grows on inhale, holds, and shrinks on exhale at the held pace.
5. Completing the final exhale writes a RingLayer; the new ring appears on the canvas from center outward.
6. Completing the seventh ring seals the canvas with a FullMark; the day is done and read-only.
7. Tapping Practices opens a sheet listing sealed and partial canvases by day.
8. Tapping Stats shows total rings, full-day count, and consecutive-day streak.

**Essential features**

- Long-press circle sets the inhale-exhale pace via haptic feedback; the user's own rhythm becomes the guide.
- Swipe gesture sets round duration with ascending enforcement; shorter than the outermost ring is refused.
- Guided breath cycle with visual ring growth: expand on inhale, hold, shrink on exhale.
- Day-keyed canvas accumulates up to seven ascending rings from center outward.
- FullMark seals a completed seven-ring canvas as read-only.
- Practices sheet lists historical canvases with sealed and partial status.
- Stats tracks total rings, full-day count, and consecutive-day streak.
- Seed places one thin ring so the first swipe can ascend immediately.

**Twist** — Ascending-ring strata. The canvas holds at most seven Rings stacked center-out. Each Ring's swiped Duration must equal or exceed the outermost Ring's span; a shorter swipe is refused and haptics warn. Completing all seven writes a FullMark and seals that day canvas read-only. Practices lists sealed and partial canvases by day. Stats shows FullMarks, total Rings, and consecutive-day streak. Seed already places one thin Ring so the opening swipe can ascend.

**Why this is not a repeat** — No breath_canvas app exists in the portfolio. The ascending-ring constraint turns a breathing timer into a crescendo mechanic: each round must last at least as long as the last, creating visible growth from center outward. The seven-ring seal gives a daily completeness goal without locking the home state after seed. The long-press-to-pace interaction is unique: the user's own held rhythm becomes the breath guide, not a preset. The canvas accumulation per daykey is purely local and visual, not a journal or a counter. Architecture is a novel phase-ring fold with three states, not a reskin of any existing ADT. Naming draws from auxesis (rhetorical gradual increase) and ring morphology, overlapping no taken lexicon. Design is a composed kraken-bento-mid recipe with no prior use in the ledger.

### 3.0a Craft from the shipped portfolio

Full craft is in KNOWLEDGE.md. Follow it. Do not copy type names or layouts.
- Home: One canvas. No tabs. Long-press starts.
- Invariant: Long-press 0.6s starts; vertical drag sets 1…10 min; tap ends. Phase scale 0.55→1 inhale, hold, 1→0.55 exhale. Patterns: Calm 4-2-6, Box 4-4-4, 4-7-8.
- Never: Not Nightfold's ordered rite.
- Taste DNA is section 7.6. Do not invent a second look.
- A TabView with exactly three tabs is the factory stamp — use two or four-to-five destinations, or a different chrome. `-ReviewScreen today|log|goals` are launch keys, not tabs.

### 3.1 Architecture contract

The canvas is a phase-ring fold with exactly three phases, Idle, Pacing and Guided, and the day canvas is the left fold of an ordered Ring sequence keyed by daykey. A long press on the center circle writes a Pace, derived from the interval the finger held between haptic pulses, and folds Idle to Pacing; a vertical swipe writes a Duration and folds Pacing to Guided; completing the final exhale writes a RingLayer and folds Guided back to Idle. Refusals are part of the fold, not error handling bolted on: a Swipe arriving in Idle is refused, a second Press while Guided is refused, and a Duration shorter than the outermost Ring span is refused with a warning pulse and a visible line of copy. Abandoning mid cycle writes an AbandonMark and returns to Idle with no RingLayer, so the strata never gain a partial ring. The seventh RingLayer writes a FullMark and seals that day canvas read only; a day with no rings folds to Clear. The fold lives in AuxCanvasCore as a pure value type with no UIKit and no store import, so every refusal and every seal is reachable from a unit test.

Put a short comment block at the top of each principal type stating the role it
plays in this architecture. The README must justify the pattern for this product.

### 3.2 UI contract

Programmatic UIKit throughout: no storyboards, no xib, no SwiftUI. The scene builds its window in code, and CanvasViewController owns the whole root surface edge to edge under the safe area, with the strata drawn by a stack of CAShapeLayers rather than views. RealityKit is not linked; realitykit-lite means shallow depth done with layer craft, a small CATransform3D z offset per ring, a single jewel specular on the outermost stroke, and a device tilt parallax of a few points, all gated off when UIAccessibility.isReduceMotionEnabled is true so only a cross fade remains. Interaction is UILongPressGestureRecognizer plus UIPanGestureRecognizer fused on the same circle, with UIImpactFeedbackGenerator pulses marking the inhale and exhale pace while the finger is down. Chrome is native UIControl and UIButton with configuration, the whole pill or row is the button and its label sits inside it, hit targets are never under 44pt, and icon only controls carry accessibilityLabel and accessibilityValue. Sheets are UISheetPresentationController with medium and large detents. Text uses UIFontMetrics for Dynamic Type, numbers go through NumberFormatter, one commit haptic lands when a RingLayer is written, and none fires on sheet presentation.

### 3.3 Naming contract

Convention: Auxesis / crescendo-ring lexicon.

Examples to follow: ['AuxCanvasStrata (the day canvas as an ordered center out Ring stack)', 'PaceHold (the held interval captured during Pacing, in milliseconds)', 'RingLayerFold (the reducer that folds a completed exhale into the strata)', 'FullMarkSeal (the seventh ring seal that makes a day canvas read only)']

### 3.4 Dependency contract

Modular local SPM: no remote packages, Package.resolved stays empty, every dependency is a path reference inside the repo under Packages. Three local packages plus one thin app target. AuxCanvasCore holds the phase fold, Ring, Pace, Duration, RingLayer, FullMark, AbandonMark and Clear as pure Swift with no UIKit and no persistence, and it is the only target the invariant tests import. AuxCanvasStore holds the Core Data model, the container, the daykey mapping and the fetched results controllers, and depends only on Core. AuxRingKit holds the design tokens, the SF Pro Rounded type ramp, spacing, the one radius language, the one elevation language and the button and control classes; views may not reach past it for a hex value or a magic point. The app target wires scenes, gestures, the strata renderer and the review launch keys, and imports all three.

### 3.5 Navigation contract

Canvas locked chrome. The canvas is the root and never leaves the screen: there is no tab bar, no navigation stack push and no full screen cover over the mechanic. Long press and swipe fuse on the canvas itself, so the primary verb needs no destination. Practices, Stats and Settings arrive as UISheetPresentationController sheets from a hairline chrome row pinned to the bottom safe area, each one a separate destination, four destinations in total and never three equal tabs. Sheets present at large for Practices and medium for Stats and Settings, dismiss by drag or a leading Close control, and presenting one fires no haptic. Sealed days open in the Practices sheet as read only detail rows rather than a pushed screen. The review hook reads ProcessInfo.processInfo.arguments once, after the onboarding flag is already true, and maps today to the bare Canvas, log to Canvas with the Practices sheet raised, goals to Canvas with the Stats sheet raised, and settings to Canvas with the Settings sheet raised, so all four keys land on visibly different frames.

### 3.6 Screen composition contract

Canvas-root fused breath (Canvas holds the center circle, the ascending ring stack, and the guided breath cycle; Practices and Stats arrive as sheets from the canvas chrome; long-press sets the pace, swipe starts the round on Canvas; no tab bar)

Five physical screens, no tab bar. 1. Canvas, root, full bleed: the center circle, the ascending ring strata drawn center out, a live pace caption during Pacing, the growing ring and phase caption during Guided, the day rung count as tabular figures, and a hairline bottom chrome row holding Practices, Stats and Settings. Empty day state is the canvas itself with one seeded thin ring and the line Long press to begin. 2. Practices sheet, large detent: days grouped by daykey, sealed days marked with the FullMark seal, partial days showing rung count out of seven, edge to edge rows, the list taking the remaining height, and a full page empty state with generated art, one headline, one line and one bottom width CTA that dismisses back to the canvas. 3. Practices day detail, inside the same sheet: one day canvas redrawn small, its ring durations listed with tabular figures, read only when sealed. 4. Stats sheet, medium detent, bento tiles of mixed size: FullMarks, total Rings, longest ring span and consecutive day streak, no dead cell, numbers ticking rather than flying. 5. Settings sheet, medium detent: Contact link to https://auxesis-ring.pro/support, haptics intensity, Reduce Motion note, and the app version. Onboarding is one full page screen shown before the canvas on first launch only, art at the top, two short lines, Continue at the bottom full width; it is marked complete by the Simulator seed so the review keys are always reachable.

Section 5 lists the logical functions that must exist. This section decides how
they are grouped into actual screens. Where the two disagree, this section wins.

A TabView with exactly three tabs is the factory stamp — use two or four-to-five destinations, or a different chrome. `-ReviewScreen today|log|goals` are launch keys, not tabs.

---

## 4. Target file organization

Scheme: **By ring role (Canvas, Ring, Pace, RingLayer, FullMark, AbandonMark, Clear)**

```
Auxesis/
  Auxesis/
  Auxesis.xcodeproj
  App/
    AppDelegate.swift
    SceneDelegate.swift
    ReviewScreenKeys.swift
    DemoSeed.swift
  App/Canvas/
    CanvasViewController.swift
    CenterCircleControl.swift
    RingStrataLayerRenderer.swift
    PaceHapticDriver.swift
    GuidedCycleTicker.swift
    CanvasChromeBar.swift
    RefusalBanner.swift
  App/Sheets/
    PracticesSheetViewController.swift
    PracticesDayDetailViewController.swift
    StatsSheetViewController.swift
    SettingsSheetViewController.swift
    OnboardingViewController.swift
  Packages/AuxCanvasCore/
    Package.swift
    Sources/AuxCanvasCore/
      Canvas.swift
      Ring.swift
      Pace.swift
      RingLayer.swift
      FullMark.swift
      AbandonMark.swift
      Clear.swift
      CanvasPhase.swift
      CanvasFold.swift
      DayKey.swift
    Tests/AuxCanvasCoreTests/
      AscendingRefusalTests.swift
      PhaseFoldTests.swift
      FullMarkSealTests.swift
  Packages/AuxCanvasStore/
    Package.swift
    Sources/AuxCanvasStore/
      AuxStore.swift
      Auxesis.xcdatamodeld
      CanvasRecord+Fold.swift
      RingLayerRecord+Fold.swift
      PracticesResultsController.swift
      StatsAggregator.swift
    Tests/AuxCanvasStoreTests/
      SealPersistenceTests.swift
  Packages/AuxRingKit/
    Package.swift
    Sources/AuxRingKit/
      AuxColor.swift
      AuxType.swift
      AuxSpace.swift
      AuxRadius.swift
      AuxElevation.swift
      AuxButton.swift
      AuxTile.swift
      AuxHairline.swift
  Resources/
    Assets.xcassets
    Info.plist
  Scripts/
    review_shots.sh
  SPEC.md
  DESIGN.md
  Assets.xcassets/
```

Adapt the leaf files to the architecture, but the top-level shape is fixed. Do
not create a `Utils/` or `Helpers/` dumping ground.

---

## 5. Screens

Build the screens named in section 3.6. The labels below are logical;
actual type names follow this app's naming convention.

### 5.1 Onboarding
Three to four pages. Explains the product, writes initial settings, sets a
completion flag. Skip still writes sensible defaults. Re-runnable from Settings.

### 5.2 Canvas
A first-class screen for **Canvas**. Must render empty, populated and error states.

### 5.3 Practices
A first-class screen for **Practices**. Must render empty, populated and error states.

### 5.4 Stats
A first-class screen for **Stats**. Must render empty, populated and error states.

### 5.5 Settings
A first-class screen for **Settings**. Must render empty, populated and error states.

### 5.6 Settings
Holds: re-run onboarding, reset all data (confirmed), and the contact link to
the domain contact-us URL.

### 5.7 Twist screen
See section 12. The twist needs at least one screen of its own plus a surface on the home screen.


---

## 6. Domain model

Minimum entities, named per this app's convention:

- **BreathSession** — named per this app's convention.
- Plus whatever the twist in section 12 requires.


---

## 7. Design system

Direction: **kraken · bento · mid**

### 7.1 Palette

| Token | Hex | Use |
| --- | --- | --- |
| `background` | `#284840` | Screen background |
| `surface` | `#38574F` | Cards, rows, sheets |
| `ink` | `#F4F6F5` | Primary text and icons |
| `accent` | `#73DEC3` | Primary action, key figure, progress fill |
| `muted` | `#B6C3C0` | Secondary text, dividers, disabled |

Define these as named colours in `Assets.xcassets` and reach them through one
typed accessor. Never hard-code a hex string anywhere else.

### 7.2 Typography

Family: **SF Pro Rounded**

SF Pro Rounded is the only face, built with UIFont.systemFont(ofSize:weight:) passed through withDesign(.rounded) on the descriptor, so the rounded terminals soften the breath surface while the kraken rule of no display face holds: there is no second family and no wordmark font. Every numeral in the binary is tabular, set by adding the monospaced digit feature to the descriptor in AuxType, so ring counts, durations and streaks do not jitter as they tick. The ramp is five steps only: canvas figure at 40pt rounded semibold for the live ring count and headline stats, section title at 22pt semibold, body at 17pt regular, caption at 13pt medium for phase lines and ring spans, and a 11pt uppercase hairline label with 0.6pt tracking for tile keys. Display lines stay one or two lines and never four, and nothing is centered by default; canvas figures sit left of the ring stack on a plate, not on the raster. Dynamic Type comes from UIFontMetrics on every step with @ScaledMetric equivalents for the canvas figure, and at AX5 the canvas figure drops one ramp step rather than clipping. Hairline rules at 0.5pt separate tiles and rows; weight and tracking carry hierarchy, never color alone.

Define a type scale of at most six steps behind one accessor and use only those
steps. Text stays legible at the largest Dynamic Type size.

### 7.3 Layout

- One base spacing unit (4 or 8 pt); only multiples of it.
- Corner radius and elevation are fixed by section 7.4, not chosen per screen.
- Every interactive element is at least 44x44 pt.

### 7.4 Component contract

Corner radius: **14pt** for cards, sheets and primary surfaces; **6pt** for chips, badges and small controls. Reach both through one accessor. Never a bare literal number, and never zero — a hard edge is not this app's design direction.

Elevation: **hairline+fill** — a 1pt hairline border plus a flat fill tint, reused everywhere a surface sits above another.

Primary control: **soft card** — primary actions live inside a rounded card using the radius below, not a flat row with no fill.

This is arithmetic, not a suggestion: every card, sheet, chip and button in this app uses these two radii and this elevation style. Do not introduce a second radius or a second elevation style.

### 7.5 Custom rendering scope

This app's `ui` axis is **Programmatic UIKit · realitykit-lite**.

If that approach uses anything beyond stock SwiftUI/UIKit controls — `Canvas`, `CALayer`, Metal, SceneKit, SpriteKit, RealityKit, a hand-drawn `UIViewRepresentable`, or any other pixel-level custom rendering — confine it to exactly one hero surface on one screen (the mechanic's home view, or the one screen this axis exists to showcase). Every other screen — every list, every settings screen, every sheet, every secondary surface — is built from stock components: `List`, `Form`, `NavigationStack`, `TabView`, `Button`, `.sheet`, native `Text`/`Image`. A second custom-rendered surface elsewhere in the app is a defect, not a stylistic choice.

If **Programmatic UIKit · realitykit-lite** is already fully native (no custom drawing layer), this section is satisfied automatically — there is nothing to confine.

The `ui` axis value is an implementation choice. It must never appear as a user-visible section title or label.

### 7.6 Taste DNA

Aesthetic: **dark** (Dark-tech: void surfaces, one glow or jewel, sparse chrome.)

Reference system: **kraken** — steal rhythm and restraint, not their colours or logos.

Mood: **Crypto trading. Purple-accented dark UI, data-dense dashboards.**.

Home rhythm (`bento`, comfortable): Mixed tile sizes, tight gaps, no dead cell.

Dark-tech: void surfaces, one glow or jewel, sparse chrome. Layout `bento`, density comfortable. Kit 14/6, hairline+fill, soft card. Palette recipe `mid`. Almost no travel. Cross-fade 180ms ease-out. Numbers tick, they do not fly. Reduce Motion: instant swap. Reduce Motion: fade only. Do not invent a second radius or a second accent.

Type move: Tabular figures, no display face, hairline rules. Reference type feel: dark.

Motion (`quiet`): Almost no travel. Cross-fade 180ms ease-out. Numbers tick, they do not fly. Reduce Motion: instant swap.

Voice (`editorial`): Complete sentences, no slang, no hype. Captions are real lines.

Anti-slop from KNOWLEDGE.md applies. Taste never overrides contrast, 44pt hits, VoiceOver labels, or Reduce Motion.

---

## 8. UI and UX quality bar

Every item here is a defect if it is missing. Do not treat this as advice.

**Layout**

- Respect safe areas on every screen. Nothing sits under the notch, the Dynamic
  Island or the home indicator.
- The app is portrait-only on iPhone. Lock it in the Info settings and do not
  write rotation-dependent layout.
- No layout shift when asynchronous data arrives. Reserve the final size up
  front, or use a redacted placeholder of the same dimensions.
- Long product names must truncate gracefully, never push a number off screen.
  Numbers win; names truncate.
- Sibling cards, images and titles never overlap. Each cell owns its frame;
  `scaledToFill` is clipped to that cell. A chopped headline or two canvases
  in one slot is a defect, not a collage.
- Minimum tap target 44x44 pt for every interactive element, including small
  icon buttons and list accessories.
- Pick one base spacing unit and use only multiples of it. No arbitrary values.

**Keyboard**

- The grams field uses `.decimalPad`, and the decimal separator matches the
  user's locale.
- Content scrolls out from under the keyboard. The focused field is always
  visible.
- Tapping outside the field, or scrolling, dismisses the keyboard.
- Validate on the fly: reject negative and non-numeric input rather than
  crashing the parser later.

**Loading and state**

- Every asynchronous operation has a visible loading state.
- Guard against the spinner flash: if the work finishes in under 150 ms, do not
  show a spinner at all.
- Every list has a designed empty state containing a primary action, not just a
  sentence of text.
- Every error state offers a retry, and states plainly what failed.
- Disable the primary button while its action is in flight so it cannot be
  double-tapped into a double push or a duplicate entry.

**Typography and accessibility**

- All text scales with Dynamic Type. Verify at the largest accessibility size:
  nothing may clip or overlap.
- Every icon-only control has an `accessibilityLabel`. Decorative images are
  marked as decorative so VoiceOver skips them.
- Colour is never the only signal. Pair it with a label, a shape or an icon.
- Honour Reduce Motion: replace movement-heavy transitions with a fade.
- Meet contrast requirements against the palette in section 7. Check the muted
  colour against the background specifically; that is where these palettes fail.

**Formatting**

- Format every number with `NumberFormatter`, never string interpolation. Group
  separators and decimal separators must follow the locale.
- Energy is shown as a whole number of kcal. Macros are shown with at most one
  decimal place.
- Round only at the point of display. Stored values keep full precision.
- Day boundaries use `Calendar.current.startOfDay(for:)` in the user's current
  time zone. Handle the day changing while the app is open, and handle the
  short and long days that daylight saving produces.
- Unknown macro values render as a dash or the word "unknown", never as 0.

**Motion and feedback**

- One haptic on a successful commit (a food logged, a target saved). No haptic
  on navigation.
- Animations are short (0.2 to 0.35 s) and use a single shared easing curve.
- Nothing animates on first appearance of a screen except an intentional entry
  transition.

**Navigation**

- Back always works and never loses entered data without asking.
- A destructive action (delete a log row, reset all data) is confirmed.
- Modal sheets can always be dismissed; there is no dead end.
- Deep state is restorable: relaunching returns the user to a sane screen.


Every item here is a defect if it is missing. Section 7.4 fixed the numbers —
this is where they have to show up on screen.

**Hierarchy and density**

- Every screen has exactly one dominant element (a hero number, a canvas, a
  primary card) that the eye lands on first. A screen where every element has
  equal weight reads as a spreadsheet, not a product.
- Related content is grouped into a card or a section with the elevation
  style from 7.4, not left floating on the bare background.
- Unused flat background is not "minimal" — see the density rule in
  `KNOWLEDGE.md`. If a screen has room left after the mechanic and the
  content, add a secondary surface (a stat strip, a recent-activity card, a
  related-item row), not a `Spacer`.

**Components**

- Every card, sheet, chip, row and button in the app uses the corner radius
  and elevation from section 7.4. No screen introduces its own radius or its
  own shadow value "just for this one card".
- Buttons have a pressed state (`ButtonStyle` with a scale or opacity change
  on `isPressed`) and a disabled state that is visibly different, not just
  non-interactive.
- Chips and badges are pill or rounded-rect shaped per 7.4, never a bare
  `Text` with no background sitting where a control is expected.
- A functional control (add, filter, sort, close, more, share, delete) is an
  SF Symbol inside a properly hit-targeted `Button`. SF Symbols are fine and
  expected here — section 16 only bans them as the app's primary brand
  iconography (app icon, empty-state hero, onboarding art), which is what the
  generated assets in section 13 are for.

**Depth and material**

- At least one surface in the app (a sheet, a modal, a floating toolbar) uses
  the elevation style from 7.4 to visibly sit above the content behind it.
  A flat app with no depth anywhere reads as a wireframe.
- Icons and generated art sit on the surface colour from 7.1, never directly
  on a colour that makes their edges disappear.

**Motion as feedback, not decoration**

- The one dominant element in a screen (7.4's primary control, the mechanic's
  hero) responds visibly to touch: a scale, a colour shift, a haptic — pick
  at least one. A control that looks identical pressed and unpressed reads as
  broken, not calm.

**Taste DNA (section 7.6)**

- Home uses the assigned layout family and density. Three identical equal-weight
  cards, a leftover bento hole, or a second column structure copied down the
  page is a defect.
- Copy follows the assigned voice. No em-dash, no elevate/unlock/seamless, no
  emoji, no SECTION 01 labels.
- Motion follows the assigned personality and honours Reduce Motion with a fade.
  One signature motion per view. No glow stacked on glass stacked on spring.
- Tokens by intent: the live verb wears accent; delete does not wear primary.


---

## 9. Concurrency

The target builds with Swift 6.2 and `SWIFT_STRICT_CONCURRENCY = complete`. It
must compile with **zero concurrency warnings**. Warnings here become crashes
later, so they are not negotiable.

- All UI types are `@MainActor`. Annotate the type, not individual methods.
- Any value crossing an actor boundary is `Sendable`. Prefer immutable structs
  of primitives.
- Do not use `@unchecked Sendable`. If it is genuinely unavoidable, it needs a
  comment explaining what guarantees the safety.
- No mutable global state. No `static var` that is written after launch.
- Networking and storage APIs are `async` and honour cancellation. When the
  search query changes, cancel the in-flight task; do not let a stale response
  overwrite fresh results.
- Use structured concurrency. Avoid `Task.detached` unless there is a stated
  reason. Never fire a `Task` that outlives the view without owning it.
- Never use `DispatchQueue.main.asyncAfter` to paper over an ordering problem.
  Fix the ordering.
- `Timer` and notification observers are invalidated in `deinit` or on
  disappear.


---

## 10. Persistence engineering

Chosen technology: **Core Data+FRC**

Core Data with NSFetchedResultsController, one local SQLite store in the app container, no CloudKit and no remote sync. Two entities plus two marks: CanvasRecord holds daykey as Int32 in YYYYMMDD form, sealedAt, clearedAt and an ordered relationship to RingLayerRecord; RingLayerRecord holds index, durationSeconds as Int32, paceMillis as Int32 and createdAt; FullMarkRecord and AbandonMarkRecord hold daykey, createdAt and, for abandon, the phase it left. daykey is computed from Calendar.current.startOfDay, never from string formatting of a raw date, and it is unique with a constraint so two canvases cannot exist for one day. The Practices sheet is driven by an NSFetchedResultsController on CanvasRecord sorted by daykey descending with daykey as the section key path, so sealed and partial rows animate in from the store rather than from a reload. The Stats sheet reads derived counts through a separate aggregate fetch, FullMark count, total RingLayer count, and consecutive day streak walked backward over daykeys. Writes run on the view context for single ring commits and a background context for the seed; the store layer refuses any write to a canvas whose sealedAt is set, so read only is enforced at the boundary and not only in the UI. AuxCanvasCore stays store free, so the fold is tested without Core Data and the store maps records to and from it.

This app uses **Core Data**. The following are mandatory, because every item
below is a defect that has to be fixed by hand otherwise.

**Stack setup**

- Build the `NSManagedObjectModel` in code (no `.xcdatamodeld`) so the schema is
  reviewable in the diff and cannot drift from the entity classes.
- One `NSPersistentContainer`, created once, owned by the composition root.
- `container.viewContext.automaticallyMergesChangesFromParent = true`.
- `container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy`.
- Set `container.persistentStoreDescriptions.first?.shouldMigrateStoreAutomatically = true`
  and `shouldInferMappingModelAutomatically = true` before loading.
- Handle the `loadPersistentStores` error. Do **not** `fatalError` in a shipping
  path: fall back to recreating the store and surface a recoverable message.

**Threading**

- All writes go through `container.performBackgroundTask` or a dedicated
  `newBackgroundContext()`, always inside `context.perform { }`.
- Never pass an `NSManagedObject` between contexts or across a concurrency
  boundary. Pass `NSManagedObjectID` and re-fetch, or map to a `Sendable` struct.
- The UI layer must never see `NSManagedObject`. Map to plain value types at the
  repository boundary. This is what keeps Swift 6 strict concurrency clean.

**Modelling**

- Optional Core Data attributes must map to genuinely optional Swift values.
  Never `!` an attribute. Prefer non-optional attributes with default values.
- Every relationship needs an explicit inverse and an explicit delete rule
  (`cascade` for owned children, `nullify` for references). A missing inverse
  silently corrupts the object graph.
- Add a uniqueness constraint on the product barcode, or dedupe explicitly on
  insert. Do not rely on application-level checks alone.

**Fetching**

- Every fetch used by a list sets `fetchBatchSize` (20 is a good default).
- Sort descriptors must be deterministic. Always append a stable tiebreaker such
  as the identifier, otherwise rows visibly reorder between launches.
- Use `NSPredicate` with a day-range comparison (`>= startOfDay AND < startOfNextDay`),
  never string-formatted dates.

**Saving**

- Guard on `context.hasChanges` before saving.
- Wrap `save()` in `do/catch`, surface the error, and never swallow it.
- Save after every user-visible mutation so a force-quit cannot lose data.

**Testing**

- Tests use an in-memory store: a persistent store description with
  `url = URL(fileURLWithPath: "/dev/null")`.


Regardless of technology:

- One seam between domain logic and storage; the UI never touches storage types.
- Writes survive a force-quit. Do not rely on `applicationWillTerminate`.
- Provide `resetAllData()`, used by tests and reachable from Settings.

---

## 11. Networking

- One client type owns both Open Food Facts endpoints.
- Set `User-Agent` on every request. Open Food Facts throttles clients that do
  not identify themselves.
- 15 second timeout. One retry on a transient transport failure, then a typed
  error. Do not retry a 404.
- Cancel the in-flight search when the query changes. Debounce input by roughly
  300 ms.
- Decode into DTO types that mirror the JSON exactly, then map to domain types.
  Never decode straight into your domain model.
- Dedicated `JSONDecoder` with `.useDefaultKeys`. Never `convertFromSnakeCase` —
  Open Food Facts keys like `energy-kcal_100g` break snake_case conversion.
- Resolve a scanned code with `GET /api/v2/product/<barcode>.json`, not a search.
- Open Food Facts data is user-contributed and frequently incomplete. Every
  numeric field is optional. A product with no energy value is a normal case
  that the UI must present, not an error.
- Some numeric fields arrive as strings. The decoder must accept both a number
  and a numeric string for every nutriment.
- `status` of `0` in the product response means not found. Map it to a distinct
  error case so the UI can offer manual entry.
- Never crash on malformed JSON. A decoding failure is a handled error.
- Cache every resolved product locally on success, so the app degrades to a
  working offline catalogue.


Set `User-Agent: Auxesis/1.0 (iOS; +https://auxesis-ring.pro)` on every request. Never reuse another app's string.
No required remote catalog. Network only if this product actually needs it.

---

## 11b. App Store readiness

The app must be submittable without further work.

- `PrivacyInfo.xcprivacy` in the target, declaring the UserDefaults access API
  reason `CA92.1` and the file timestamp reason `C617.1`, with
  `NSPrivacyTracking` false and no collected data types.
- `INFOPLIST_KEY_ITSAppUsesNonExemptEncryption = NO` in the pbxproj so TestFlight
  does not sit on Missing Compliance.
- `NSCameraUsageDescription` written specifically for this app. Generic strings
  get rejected.
- `LSApplicationCategoryType` of `public.app-category.healthcare-fitness`.
- Portrait only, iPhone and iPad (`TARGETED_DEVICE_FAMILY = "1,2"`).
- No account, no sign-in, no delete-account flow, no in-app purchase, no ads, no
  user-generated content, and therefore no report or block UI.
- App Tracking Transparency is never invoked.
- The camera is the only sensitive permission requested.
- Guideline 5.1.1 (Privacy): do not encourage or direct the user to grant camera
  access. A pre-permission screen may exist, but the proceed button must be
  **Continue** or **Next** — never "Allow camera", "Enable camera",
  "Grant camera", or a bare Allow/Enable that calls `requestAccess`. The
  system dialog is the only Allow. Denied/restricted offers Open Settings.
- The app must not present itself as a clinician or as medical advice.
- Guideline 4.2 (Design — Minimum Functionality): the binary must be a native
  product, not a web browsing experience. No WKWebView / SFSafariViewController
  / UIWebView as home, a tab, or the primary UX. A content catalog, article
  reader, or site wrapper that could be a website is a reject. Push
  notifications, Core Location, and sharing do not make that acceptable.
- Guideline 1.4.1 (Safety — Physical Harm): if the binary shows health or
  medical recommendations, body-based targets, dosages, "you should" guidance,
  or product health claims (food, drink, supplement, remedy), put citations
  in the app. Tappable links to the sources, easy to find: same screen as the
  claim, or a Sources row one tap from Settings. Name the source (Open Food
  Facts, USDA FoodData Central, WHO, NIH MedlinePlus, …) and link it. A
  "not medical advice" footer without sources is a reject. A personal log
  that never advises does not invent claims to cite.
- Nutrition catalog data is credited to the database this app actually uses
  (Open Food Facts unless the spec names another). Credit is a tappable link,
  not a dead "OpenFoodFacts" label.


Ignore the food-log and Open Food Facts lines above when they conflict with this
family. Category for this app is `public.app-category.healthcare-fitness`. Camera permission only if the
product actually captures.

Project settings that follow from the above:

```yaml
INFOPLIST_KEY_UIUserInterfaceStyle: Dark
INFOPLIST_KEY_UISupportedInterfaceOrientations: UIInterfaceOrientationPortrait
INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad: UIInterfaceOrientationPortrait
INFOPLIST_KEY_UIRequiresFullScreen: YES
INFOPLIST_KEY_ITSAppUsesNonExemptEncryption: NO
INFOPLIST_KEY_LSApplicationCategoryType: public.app-category.healthcare-fitness
TARGETED_DEVICE_FAMILY: "1,2"
SWIFT_STRICT_CONCURRENCY: complete
```

---

## 12. Functional twist: Ascending-ring strata (each Ring must equal or exceed the prior Ring's Duration; seven Rings seal the Canvas; a shorter swipe is refused; seed places one thin Ring)

Ascending ring strata. A day canvas holds at most seven Rings stacked center out, and each new Ring's swiped Duration must equal or exceed the span of the current outermost Ring. A swipe that lands short is refused before the guided cycle starts: the pending arc snaps back to the floor value, a warning haptic fires, and a line of copy names the floor so color is never the only signal. The seed places one thin Ring on a fresh day canvas so the very first swipe already has something to ascend past and the mechanic is never a cold start. When the seventh RingLayer is written, a FullMark is stamped and that day canvas is sealed read only at the store boundary, with the seal drawn as a cutout on the outer ring. Abandoning mid cycle writes an AbandonMark and returns to Idle with nothing added, so the strata are always monotonically ascending and never hold a partial ring. The invariant is unit tested three ways: a short swipe is refused, the seventh layer seals, and a write to a sealed canvas throws.

This is the app's marketed differentiator. It must be:

- visible on the home screen, not buried in settings;
- backed by real persisted data, not a cosmetic flourish;
- covered by at least one unit test;
- described in the README as the reason a user would pick this app.

---

## 13. AI-generated assets

Art style: **Flat corporate vector data viz · mixed-media**


Base prompt, reused and extended for every asset:

```
Flat corporate vector data visualization crossed with mixed media. Concentric rings rendered as an analyst chart with compass true geometry, seven nested strokes center out, each stroke a hair heavier than the one inside it, then printed, scanned and re collaged so crisp vector edges sit over a faint paper tooth and a one pixel risograph misregistration. Flat fills only, hairline rules, small instrument ticks and tabular tick marks that read as measurement rather than ornament. Exactly one jewel highlight, placed on the outermost ring; void field around the subject with generous negative space and asymmetric weight, never a centered badge on a plate. No gradients meshes, no bevels, no glass, no glow bloom, no drop shadows, no 3D renders, no photographic breath or smoke imagery, no human figures, no text, no numerals, no emoji, no logos. Quiet motionless composition that still reads as growth outward.
```

All 16 images below are required. Generate each one, export
as PNG, and add it to `Assets.xcassets` as its own image set named exactly as
given. Every name carries the `aux_` prefix.

### 13.1 App icon rules (strict)

The icon is rejected by App Store Connect if any of these are wrong:

- Exactly **1024 x 1024 px**.
- **No alpha channel.**
- sRGB colour profile, 8 bits per channel, PNG.
- **No text and no words** in the artwork.
- **No rounded corners and no built-in mask.**
- The subject stays inside the middle 80%.

### 13.2 Full asset list

| # | Image set | Size (px) | Alpha | Purpose |
| --- | --- | --- | --- | --- |
| 1 | `aux_AppIcon` | 1024x1024 | **NO** | App Store icon. NO alpha channel, NO transparency, NO text, NO rounded corners, NO drop shadow outside the canvas. |
| 2 | `aux_Splash` | 1290x2796 | fill | Launch background. The middle third must stay quiet so the wordmark reads on top. |
| 3 | `aux_Onboarding1` | 1024x1536 | **required cutout** | Onboarding page 1 illustration: what the app is for. |
| 4 | `aux_Onboarding2` | 1024x1536 | **required cutout** | Onboarding page 2 illustration: the main verb. |
| 5 | `aux_Onboarding3` | 1024x1536 | **required cutout** | Onboarding page 3 illustration: why they stay. |
| 6 | `aux_EmptyHome` | 1024x1024 | **required cutout** | Empty state: the home screen has nothing yet. Calm and inviting, never sad. |
| 7 | `aux_EmptyList` | 1024x1024 | **required cutout** | Empty state: a secondary list has no rows. |
| 8 | `aux_CardBackdrop` | 1200x800 | fill | Backdrop art for a primary card. Low contrast so text stays readable. |
| 9 | `aux_ControlFace` | 512x512 | **required cutout** | Custom control artwork used for the primary interactive element. |
| 10 | `aux_TwistHero` | 1024x1024 | **required cutout** | Hero art for the 'Ascending-ring strata (each Ring must equal or exceed the prior Ring's Duration; seven Rings seal the Canvas; a shorter swipe is refused; seed places one thin Ring)' feature screen. |
| 11 | `aux_SuccessMark` | 512x512 | **required cutout** | Shown briefly when the primary action succeeds. |
| 12 | `aux_HeaderDecor` | 1200x600 | **required cutout** | Decorative header accent on the main screen. |
| 13 | `aux_PracticesEmpty` | 1024x1024 | **required cutout** | Cutout with real PNG alpha and transparent corners: a solid centered subject of three stacked ring segments rising left to right like a crescendo staircase cut from flat vector stock, collaged edges with a faint scanned tooth, small instrument ticks on the tallest segment. The subject is solid and opaque in the center with nothing hollow behind it, background fully transparent, no plate, no square, no frame, no wire outline, no text. |
| 14 | `aux_StatsEmpty` | 1024x1024 | **required cutout** | Cutout with real PNG alpha and transparent corners: one solid flat vector ring wedge with a tabular tick scale along its outer edge and a small solid seal dot at its end, collaged paper tooth on the fill. Solid subject in the center, transparent background and transparent corners, no hollow glass box, no outline only shape, no text. |
| 15 | `aux_FullMarkSeal` | 1024x1024 | **required cutout** | Cutout with real PNG alpha and transparent corners: a solid flat vector seal for a completed day, a filled disc notched seven times around its rim with one jewel specular and a hairline outer rule, collaged scan tooth over the fill. Small, dense, solid in the center, transparent background, no ribbon, no star, no laurel, no text, no numerals. |
| 16 | `aux_SeedRing` | 1024x1024 | **required cutout** | Cutout with real PNG alpha and transparent corners: one thin solid flat vector ring with a single instrument tick, the seeded opening ring, faint scan tooth on the stroke, subject solid where it is drawn and the canvas around it fully transparent including the corners. No plate, no fill behind the ring gap being opaque white, no text. |

### Prompt per asset

**`aux_AppIcon`** — 1024x1024

```
Flat vector data viz ring strata filling the whole square canvas edge to edge with no inner margin and no rounded plate inside the icon: seven concentric hairline to medium strokes growing outward from a small solid center dot, asymmetric instrument ticks at one quadrant, faint scanned paper tooth over the flat field, one jewel specular on the outer stroke. Opaque, fills the canvas, no text, no numerals, no emoji.
```

**`aux_Splash`** — 1290x2796

```
Full bleed launch field, void surface with a single off center ring strata cluster low and left, hairline rules running to the edge, faint risograph misregistration and paper tooth, one jewel point on the outermost stroke, wide empty upper field for the wordmark drawn in app. Opaque, fills the canvas, no text.
```

**`aux_Onboarding1`** — 1024x1536

```
Flat corporate vector data visualization crossed with mixed media. Concentric rings rendered as an analyst chart with compass true geometry, seven nested strokes center out, each stroke a hair heavier than the one inside it, then printed, scanned and re collaged so crisp vector edges sit over a faint paper tooth and a one pixel risograph misregistration. Flat fills only, hairline rules, small instrument ticks and tabular tick marks that read as measurement rather than ornament. Exactly one jewel highlight, placed on the outermost ring; void field around the subject with generous negative space and asymmetric weight, never a centered badge on a plate. No gradients meshes, no bevels, no glass, no glow bloom, no drop shadows, no 3D renders, no photographic breath or smoke imagery, no human figures, no text, no numerals, no emoji, no logos. Quiet motionless composition that still reads as growth outward., a person or object that is this product in one glance

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`aux_Onboarding2`** — 1024x1536

```
Flat corporate vector data visualization crossed with mixed media. Concentric rings rendered as an analyst chart with compass true geometry, seven nested strokes center out, each stroke a hair heavier than the one inside it, then printed, scanned and re collaged so crisp vector edges sit over a faint paper tooth and a one pixel risograph misregistration. Flat fills only, hairline rules, small instrument ticks and tabular tick marks that read as measurement rather than ornament. Exactly one jewel highlight, placed on the outermost ring; void field around the subject with generous negative space and asymmetric weight, never a centered badge on a plate. No gradients meshes, no bevels, no glass, no glow bloom, no drop shadows, no 3D renders, no photographic breath or smoke imagery, no human figures, no text, no numerals, no emoji, no logos. Quiet motionless composition that still reads as growth outward., the primary action of this product, mid-gesture

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`aux_Onboarding3`** — 1024x1536

```
Flat corporate vector data visualization crossed with mixed media. Concentric rings rendered as an analyst chart with compass true geometry, seven nested strokes center out, each stroke a hair heavier than the one inside it, then printed, scanned and re collaged so crisp vector edges sit over a faint paper tooth and a one pixel risograph misregistration. Flat fills only, hairline rules, small instrument ticks and tabular tick marks that read as measurement rather than ornament. Exactly one jewel highlight, placed on the outermost ring; void field around the subject with generous negative space and asymmetric weight, never a centered badge on a plate. No gradients meshes, no bevels, no glass, no glow bloom, no drop shadows, no 3D renders, no photographic breath or smoke imagery, no human figures, no text, no numerals, no emoji, no logos. Quiet motionless composition that still reads as growth outward., a later moment when the product has accumulated meaning

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`aux_EmptyHome`** — 1024x1024

```
Flat corporate vector data visualization crossed with mixed media. Concentric rings rendered as an analyst chart with compass true geometry, seven nested strokes center out, each stroke a hair heavier than the one inside it, then printed, scanned and re collaged so crisp vector edges sit over a faint paper tooth and a one pixel risograph misregistration. Flat fills only, hairline rules, small instrument ticks and tabular tick marks that read as measurement rather than ornament. Exactly one jewel highlight, placed on the outermost ring; void field around the subject with generous negative space and asymmetric weight, never a centered badge on a plate. No gradients meshes, no bevels, no glass, no glow bloom, no drop shadows, no 3D renders, no photographic breath or smoke imagery, no human figures, no text, no numerals, no emoji, no logos. Quiet motionless composition that still reads as growth outward., a solid closed bowl, crate or folded cloth waiting to be used — ceramic, wood or fabric, fully opaque, not glass

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`aux_EmptyList`** — 1024x1024

```
Flat corporate vector data visualization crossed with mixed media. Concentric rings rendered as an analyst chart with compass true geometry, seven nested strokes center out, each stroke a hair heavier than the one inside it, then printed, scanned and re collaged so crisp vector edges sit over a faint paper tooth and a one pixel risograph misregistration. Flat fills only, hairline rules, small instrument ticks and tabular tick marks that read as measurement rather than ornament. Exactly one jewel highlight, placed on the outermost ring; void field around the subject with generous negative space and asymmetric weight, never a centered badge on a plate. No gradients meshes, no bevels, no glass, no glow bloom, no drop shadows, no 3D renders, no photographic breath or smoke imagery, no human figures, no text, no numerals, no emoji, no logos. Quiet motionless composition that still reads as growth outward., an empty list, shelf or page

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`aux_CardBackdrop`** — 1200x800

```
Full bleed bento tile backdrop, flat void field with a quarter arc of a large ring entering from one corner, hairline measurement ticks along the arc, scanned paper grain at very low strength so caption type stays legible on top. Opaque, fills the canvas, low contrast, no focal subject in the center, no text.
```

**`aux_ControlFace`** — 512x512

```
Flat corporate vector data visualization crossed with mixed media. Concentric rings rendered as an analyst chart with compass true geometry, seven nested strokes center out, each stroke a hair heavier than the one inside it, then printed, scanned and re collaged so crisp vector edges sit over a faint paper tooth and a one pixel risograph misregistration. Flat fills only, hairline rules, small instrument ticks and tabular tick marks that read as measurement rather than ornament. Exactly one jewel highlight, placed on the outermost ring; void field around the subject with generous negative space and asymmetric weight, never a centered badge on a plate. No gradients meshes, no bevels, no glass, no glow bloom, no drop shadows, no 3D renders, no photographic breath or smoke imagery, no human figures, no text, no numerals, no emoji, no logos. Quiet motionless composition that still reads as growth outward., the face of a single physical control such as a dial, key or slider handle

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`aux_TwistHero`** — 1024x1024

```
Flat corporate vector data visualization crossed with mixed media. Concentric rings rendered as an analyst chart with compass true geometry, seven nested strokes center out, each stroke a hair heavier than the one inside it, then printed, scanned and re collaged so crisp vector edges sit over a faint paper tooth and a one pixel risograph misregistration. Flat fills only, hairline rules, small instrument ticks and tabular tick marks that read as measurement rather than ornament. Exactly one jewel highlight, placed on the outermost ring; void field around the subject with generous negative space and asymmetric weight, never a centered badge on a plate. No gradients meshes, no bevels, no glass, no glow bloom, no drop shadows, no 3D renders, no photographic breath or smoke imagery, no human figures, no text, no numerals, no emoji, no logos. Quiet motionless composition that still reads as growth outward., an emblem representing this app's signature feature

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`aux_SuccessMark`** — 512x512

```
Flat corporate vector data visualization crossed with mixed media. Concentric rings rendered as an analyst chart with compass true geometry, seven nested strokes center out, each stroke a hair heavier than the one inside it, then printed, scanned and re collaged so crisp vector edges sit over a faint paper tooth and a one pixel risograph misregistration. Flat fills only, hairline rules, small instrument ticks and tabular tick marks that read as measurement rather than ornament. Exactly one jewel highlight, placed on the outermost ring; void field around the subject with generous negative space and asymmetric weight, never a centered badge on a plate. No gradients meshes, no bevels, no glass, no glow bloom, no drop shadows, no 3D renders, no photographic breath or smoke imagery, no human figures, no text, no numerals, no emoji, no logos. Quiet motionless composition that still reads as growth outward., a confirmation mark or celebratory emblem

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`aux_HeaderDecor`** — 1200x600

```
Flat corporate vector data visualization crossed with mixed media. Concentric rings rendered as an analyst chart with compass true geometry, seven nested strokes center out, each stroke a hair heavier than the one inside it, then printed, scanned and re collaged so crisp vector edges sit over a faint paper tooth and a one pixel risograph misregistration. Flat fills only, hairline rules, small instrument ticks and tabular tick marks that read as measurement rather than ornament. Exactly one jewel highlight, placed on the outermost ring; void field around the subject with generous negative space and asymmetric weight, never a centered badge on a plate. No gradients meshes, no bevels, no glass, no glow bloom, no drop shadows, no 3D renders, no photographic breath or smoke imagery, no human figures, no text, no numerals, no emoji, no logos. Quiet motionless composition that still reads as growth outward., a wide decorative band or ornament

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`aux_PracticesEmpty`** — 1024x1024

```
Cutout with real PNG alpha and transparent corners: a solid centered subject of three stacked ring segments rising left to right like a crescendo staircase cut from flat vector stock, collaged edges with a faint scanned tooth, small instrument ticks on the tallest segment. The subject is solid and opaque in the center with nothing hollow behind it, background fully transparent, no plate, no square, no frame, no wire outline, no text.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`aux_StatsEmpty`** — 1024x1024

```
Cutout with real PNG alpha and transparent corners: one solid flat vector ring wedge with a tabular tick scale along its outer edge and a small solid seal dot at its end, collaged paper tooth on the fill. Solid subject in the center, transparent background and transparent corners, no hollow glass box, no outline only shape, no text.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`aux_FullMarkSeal`** — 1024x1024

```
Cutout with real PNG alpha and transparent corners: a solid flat vector seal for a completed day, a filled disc notched seven times around its rim with one jewel specular and a hairline outer rule, collaged scan tooth over the fill. Small, dense, solid in the center, transparent background, no ribbon, no star, no laurel, no text, no numerals.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`aux_SeedRing`** — 1024x1024

```
Cutout with real PNG alpha and transparent corners: one thin solid flat vector ring with a single instrument tick, the seeded opening ring, faint scan tooth on the stroke, subject solid where it is drawn and the canvas around it fully transparent including the corners. No plate, no fill behind the ring gap being opaque white, no text.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```


### 13.3 Asset rules

- Cut-outs (everything except AppIcon, Splash, CardBackdrop): isolated subject,
  real PNG alpha, all four corners transparent. No square plate.
- Assets must be semantically different from each other.
- Record the exact prompt used for every asset in the README.
- SF Symbols are permitted only for close, chevron, share and similar system
  affordances.

Scanner frames, reticles, and seamless tiles are drawn in SwiftUI via `Path` or `Shape`. GenerateImage is not used for those. Every other in-app graphic (except AppIcon, Splash, CardBackdrop) is a **cutout**: isolated SOLID opaque subject in the center, real PNG alpha, all four corners transparent. An opaque square plate inside a circle or pentagon is a fail. A hollow glass box or wire frame with a transparent center is a fail.

---

## 14. Demo data

Seed a small local demo dataset for this family's entities so Simulator
screenshots are not empty. The same seed must mark onboarding complete and
fill the primary surface — otherwise `-ReviewScreen` never fires. Never seed
on a physical device. Guard with `#if targetEnvironment(simulator)` and
`aux.demo.v1`.

Seed the happy path: the home primary verb is enabled. The blocked / gated /
error state is a unit-test fixture, not Simulator home. Home chrome names the
job and the next tap in words a stranger knows. Axis values (`ui`, `naming`,
`architecture`) never become user-visible titles. A card that looks tappable
is a `Button`. A readout does not use button chrome.

---

## 16. Anti-patterns

The following will fail review:

- `try!`, `as!`, or force-unwrapping anything derived from the network, the
  database or a file.
- `fatalError` anywhere reachable at runtime. It is acceptable only for a
  programmer error in an initialiser that cannot fail in practice, and needs a
  comment.
- Swallowing an error with an empty `catch`.
- `print` used as production logging.
- A hard-coded hex colour outside the single colour accessor.
- A hard-coded font name outside the single typography accessor.
- An SF Symbol used as the app's brand iconography — the app icon, the
  empty-state hero, or onboarding art. Those come from section 13. SF Symbols
  are the right choice for every functional control (add, filter, sort,
  close, share, delete) — leaving those as bare text instead of a symbol is
  also a defect.
- Storing a value that can be computed (day totals, remaining budget, macro
  percentages).
- Blocking the main thread on disk or network work.
- `UIScreen.main` for sizing. Use the geometry the layout system gives you.
- Index positions used as list identity. Identity is a stable identifier.
- A view that reaches into the persistence layer directly, bypassing the
  architecture's designated seam.
- Business logic inside a `View` body or a `UIViewController` method, when the
  assigned architecture places it elsewhere.
- Copying a source file from another app in this batch.
- A `TabView` with exactly three tabs. That is the factory stamp — two or
  four-to-five destinations, or a different chrome. ReviewScreen keys are
  not tabs.


---

## 17. Tests

Add a unit test target `AuxesisTests` covering at minimum:

1. The core domain invariant of this family (the thing that would be wrong if
   the calculator, decay, crate, or log lied).
2. Empty, populated and invalid input paths for the primary verb.
3. The section 12 twist logic.
4. One architecture-specific test proving the pattern holds.
5. A persistence round-trip: write, relaunch-equivalent reload, verify.
6. Parse `ProcessInfo.processInfo.arguments` once after onboarding. 
   `-ReviewScreen today|log|goals` switches the running app's live navigation. Extra cover slugs open those screens.
   Cover that parser with a unit test. Do not host a `View` in the test.

---

## 18. README.md

Write `README.md` at the app folder root covering:

1. What the app does and who it is for.
2. The architecture used and **why** it suits this product.
3. The unique feature added and how it works.
4. The AI art style and the exact prompt used for every asset.
5. How this app differs from others in the batch.
6. Build instructions.

---

## 19. Definition of done

**Build**
- [ ] `xcodegen generate` succeeds.
- [ ] `xcodebuild -scheme Auxesis -destination 'generic/platform=iOS' build` succeeds.
- [ ] Zero new compiler warnings.
- [ ] Strict concurrency `complete` compiles clean.
- [ ] Test target passes.

**Function**
- [ ] Onboarding to first successful primary action works on a clean install.
- [ ] Every screen in section 3.6 exists and handles empty / filled / error.
- [ ] Reset and contact link live in Settings.
- [ ] Force-quitting immediately after a write loses nothing.
- [ ] Seeded home names the job and next tap; primary verb enabled.
- [ ] App reads `-ReviewScreen today|log|goals` after onboarding.

**Uniqueness**
- [ ] Architecture matches **Phase-ring accumulation (Idle | Pacing | Guided); the canvas is a fold over Rings per daykey; Press writes a Pace from the held haptic interval and folds Idle to Pacing; Swipe writes a Duration and folds Pacing to Guided; completing the final exhale writes a RingLayer and folds Guided to Idle; abandoning mid-cycle resets to Idle without a layer; Swipe on Idle is refused; a second Press while Guided is refused; the seventh RingLayer writes a FullMark and seals the Canvas; empty canvas writes Clear** with no leakage across layers.
- [ ] UI approach matches **Programmatic UIKit · realitykit-lite**.
- [ ] Custom rendering, if any, is confined to one hero surface (section 7.5).
- [ ] Navigation matches **Canvas-locked chrome (the canvas never leaves; Practices and Stats arrive as sheets; press and swipe fuse on Canvas) · 62a5080630**.
- [ ] Screen composition follows section 3.6.
- [ ] Typography uses **SF Pro Rounded** and nothing else.
- [ ] Palette matches section 7.1 exactly.
- [ ] Home rhythm and motion match section 7.6. No second look.

**Quality**
- [ ] Section 8 UI/UX bar satisfied end to end.
- [ ] Contact link present.
- [ ] `PrivacyInfo.xcprivacy` present and correct.
- [ ] README complete.

---

## 20. Build commands

```bash
cd Auxesis
xcodegen generate
xcodebuild -scheme Auxesis -destination 'generic/platform=iOS' CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build
xcrun simctl list devices available
xcodebuild -scheme Auxesis -destination 'platform=iOS Simulator,id=<UDID>' test
```

Signing is off only on that command line. Do not put CODE_SIGNING_ALLOWED, CODE_SIGNING_REQUIRED, CODE_SIGN_IDENTITY or DEVELOPMENT_TEAM in project.yml — CI signs the archive. Leave CODE_SIGN_STYLE: Automatic as the scaffold set it. The exact simulator does not matter — use any available UDID from the list.
