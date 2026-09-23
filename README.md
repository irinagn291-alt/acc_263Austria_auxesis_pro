# Auxesis

A daily breather long-presses the circle to feel a pace, then swipes a duration so the guided round files as one ring on today's ascending canvas. Each new ring must last at least as long as the last. Seven rings seal the day.

Auxesis is for someone who wants a visible crescendo, not a journal and not a preset timer.

## Architecture

The canvas is a phase-ring fold with three phases: Idle, Pacing, and Guided. The day canvas is the left fold of an ordered Ring sequence keyed by daykey.

- A long press writes a Pace from the held haptic interval and folds Idle to Pacing.
- A vertical swipe writes a Duration and folds Pacing to Guided.
- Completing the final exhale writes a RingLayer and folds Guided back to Idle.
- Abandoning mid-cycle writes an AbandonMark and returns to Idle with no layer.
- A swipe on Idle is refused. A second press while Guided is refused.
- The seventh RingLayer writes a FullMark and seals the canvas. An empty day folds to Clear.

The fold lives in `AuxCanvasCore` as a pure value type. That is why this pattern fits the product: every refusal and every seal is reachable from a unit test, and the UI cannot invent a partial ring. `AuxCanvasStore` maps records through the same fold. The app target only wires gestures, the strata renderer, and the review launch keys.

## Unique feature

Ascending-ring strata. A day holds at most seven rings stacked center out. A swipe shorter than the outermost ring is refused with a warning pulse and a line of copy. Seed places one thin ring so the first swipe already has a floor. Completing seven rings seals that day read only. Practices lists sealed and partial canvases. Stats shows sealed days, total rings, and a consecutive-day streak.

## Design

Programmatic UIKit with realitykit-lite depth: stacked `CAShapeLayer` rings, a small z offset, one jewel on the outer stroke, and a few points of tilt parallax. Reduce Motion keeps a cross-fade only. Tokens come from `AuxRingKit`. Typography is SF Pro Rounded. Chrome is canvas-locked: Practices, Stats, and Settings arrive as sheets. `-ReviewScreen today|log|goals|settings|strata` are launch arguments, not tabs.

## AI art

Style: flat corporate vector data viz crossed with mixed media.

Base prompt reused for every asset:

```
Flat corporate vector data visualization crossed with mixed media. Concentric rings rendered as an analyst chart with compass true geometry, seven nested strokes center out, each stroke a hair heavier than the one inside it, then printed, scanned and re collaged so crisp vector edges sit over a faint paper tooth and a one pixel risograph misregistration. Flat fills only, hairline rules, small instrument ticks and tabular tick marks that read as measurement rather than ornament. Exactly one jewel highlight, placed on the outermost ring; void field around the subject with generous negative space and asymmetric weight, never a centered badge on a plate. No gradients meshes, no bevels, no glass, no glow bloom, no drop shadows, no 3D renders, no photographic breath or smoke imagery, no human figures, no text, no numerals, no emoji, no logos. Quiet motionless composition that still reads as growth outward.
```

Exact prompts for each `aux_` imageset are in SPEC.md section 13.2. Imagesets are named now; pixels arrive from a later assets step.

## How this app differs

No other breath canvas exists in the portfolio. The long press writes the user's own pace. The fold has three phases and named refusals, not a reskin of an existing ADT. Naming is auxesis and ring morphology. Home is the mechanic, not a list of records and not a three-tab bar.

## Build

```bash
cd Auxesis
xcodegen generate
xcodebuild -scheme Auxesis -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build-for-testing
```
