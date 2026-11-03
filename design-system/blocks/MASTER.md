# Blocks: Flutter UI/UX standard

## Source and scope

Derived from the installed **UI UX Pro Max** skill at
`.agents/skills/ui-ux-pro-max/SKILL.md`, its mobile pre-delivery rules,
and verified local searches on 2026-11-03:

- `puzzle game --domain product`: Casual Puzzle Game, vibrant/block-based styling.
- `dragging movements --domain ux`: provide a single-pointer alternative to drag.
- `reduced motion --domain ux`: respect platform motion preferences.
- `semantics text scaling reduced motion --stack flutter`: semantics, text scaling.

The initial design-system generator returned website sections (hero,
testimonials, CTA) and a light pink palette. Those recommendations do not fit
the running game and were rejected. This file is a curated implementation
specification, not unedited generator output or a compliance certification.

## Identity and visual system

- Product: Blocks, application ID `vn.lochv.locblocks`.
- Keep the navy game surface and seven identifiable tile colors.
- Material 3 dark controls use `AppTheme.dark`; colors live in `AppColors`.
- Primary text white, supporting text white70, action/selected accents gold.
- Meaningful text contrast at least 4.5:1; selected controls use an outline,
  visible indicator and programmatic selection, not color alone.
- Tile fruit/geometric symbols are decorative original Canvas drawings.
- System/navigation icons use Flutter Material icons with accessible names.
- Use the platform font with Vietnamese support, user text scaling and natural
  wrapping; do not fetch fonts at runtime or clamp the user's text size.

## Layout and interaction

- 4/8dp spacing rhythm; default content inset 16dp, control gap 8dp.
- System buttons at least 48x48dp; visible focus/pressed feedback.
- Game board maximum 520dp, panels maximum 560dp on larger displays.
- Respect safe areas; allow vertical scrolling when height or large text
  cannot fit. Do not shrink the board indefinitely to fit landscape.
- Theme picker is scrollable, closable, and constrained to the viewport.
- Drag-to-place remains available. Alternative: tap a dock piece, then tap
  the cell where its upper-left corner should go. Tap the piece again to cancel.
- Dock/cell controls are focusable through native InkWell behavior; announce
  row, column, occupancy and selected piece state to assistive technology.
- Dense board cells retain their spatial game layout and can be below 48dp
  on small phones; the 48dp system-button rule is not asserted for every cell.
- Invalid moves retain the selected piece and show an explanatory hint.
- Save failures are visible, keep the previous selection and allow retry.
- Points, game rules and existing local progress format remain unchanged.

## Motion and feedback

- Use `MediaQuery.disableAnimationsOf(context)` for score movement/scaling.
- With reduced motion, commit moves without delayed flashes or floating score
  popups. Existing popups stop translating when the preference changes.
- Announce score and move hints with semantics; do not use animated color as
  the only feedback. Avoid focus stealing when the score changes.

## Required verification for future UI changes

- `flutter analyze --no-pub`
- `flutter test --no-pub`
- Check small phone, landscape and tablet layouts with 200% text scaling.
- Verify themes and main controls remain reachable in scrollable layouts.
- Verify both tap placement and existing drag placement preserve scoring/saves.
- Verify reduced-motion behavior and theme persistence/failure recovery.
- Visually inspect rendered Flutter previews after layout or artwork changes.

Current scope: native Flutter game (`lib/main.dart`). The legacy WebView
entry point is not redesigned. Only dark app chrome is provided; the three
tile themes are not light/dark modes. Full TalkBack usability, every system
text size and physical-device performance still require device QA.

## Integration verification (2026-11-03)

- Flutter analyze: no issues; 24 existing/new tests passed.
- Additional rendered-preview/compact-screen smoke test passed.
- Tested layout with 200% text: 375x667 phone, 812x375 landscape,
  1024x768 tablet; theme cards remain reachable and the board stays <=520dp.
- Verified tap-placement overlap rejection, valid-move persistence and reduced
  motion; existing drag/cancel regression tests remain passing.
- Measured sRGB contrast on background/panel respectively: white 17.25/15.28,
  composed white70 8.90/8.15, gold 10.33/9.15, control border 4.64/4.11.
- Visually reviewed game and picker previews with Vietnamese-capable local
  font rendering. These are test renders, not newly captured device screenshots.
- Skill license is MIT. Repo and upstream-head metadata are recorded in
  `.agents/skills/ui-ux-pro-max/UPSTREAM.json`; no global skill was installed.
- No new AAB was built or uploaded as part of this UI integration.
