# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project uses [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Formal vanilla and Fair Crisis state machines, forced-victory inventory,
  intervention matrix, gap analysis, save migration and T1–T11 test plan.
- Static validator for script structure, IDs, localization, override allow-list,
  destructive effects and accidental full vanilla copies.
- One-shot diagnostic logs for every relevant Fair Crisis transition.

### Fixed

- Redirect Cetana's initial bastille away from Fallen/Awakened Empire capitals
  while retaining the complete vanilla `synth_queen_spawn` effect. Fully
  occupied galaxies receive a minimal isolated fallback system rather than
  reverting to the FE-capital sacrifice.
- Prevent `crisis.8010` and `crisis.8015` from calling the destructive system
  wipe on FE/AE territory; retain their visual storm expansion.
- Start FE/AE normalization during the silent `synth_queen_storm` stage, before
  storm-entry damage can remove fleets.
- Retain vanilla `crisis.8050` fleet replenishment when intercepting the
  destructive branches of `crisis.8042`.
- Normalize already-active voluntary wars after loading an existing save.

### Diagnostics

- Confirmed from the inspected test saves that `crisis.8042` had set
  `weaker_navy` and that `crisis.8065` had recorded a failed default-empire
  attack. The same saves had no CFC flags and the launcher reported no enabled
  mods, so that particular test did not execute version 1.0.3.

## [1.0.3] - 2026-08-10

### Fixed

- Add the mandatory `v` prefix to `supported_version` and use `v4.4.*`, matching
  the game's `rawVersion` format (`v4.4.6`). Stellaris launchers since 3.12
  reject otherwise correct version numbers when this prefix is absent.

## [1.0.2] - 2026-08-10

### Fixed

- Match the descriptor to the launcher's `modsCompatibilityVersion` (`4.4`).
  This launcher compares against the major/minor compatibility marker rather
  than the full `rawVersion` (`v4.4.6`) and does not expand wildcard values.

## [1.0.1] - 2026-08-10

### Fixed

- Set `supported_version` to the exact validated game version (`4.4.6`) because
  the current Paradox Launcher incorrectly warned about the `4.4.*` wildcard.
- Avoid installing the repository's external `.mod` descriptor inside the mod
  content directory; only the top-level launcher descriptor and internal
  `descriptor.mod` are required.

## [1.0.0] - 2026-08-10

### Added

- Fair initial war between Cetana and Fallen/Awakened Empires.
- Selective removal of the scripted FE/AE combat damage bias.
- Neutralization of scripted FE fleet and colony destruction during this phase.
- Voluntary early-war intervention for normal empires.
- Save-game normalization before and during the initial war.
- Early-defeat integration with vanilla `crisis.23015` cleanup and All Crises
  progression.
- English and Spanish localization.
- Diagnostic logging with the `[Cetana Fair Crisis]` prefix.
- Technical vanilla analysis and reproducible test plan.

[Unreleased]: https://github.com/ikseth/stellaris_cetana_fair_crisis_mod/compare/v1.0.3...HEAD
[1.0.3]: https://github.com/ikseth/stellaris_cetana_fair_crisis_mod/compare/v1.0.2...v1.0.3
[1.0.2]: https://github.com/ikseth/stellaris_cetana_fair_crisis_mod/compare/v1.0.1...v1.0.2
[1.0.1]: https://github.com/ikseth/stellaris_cetana_fair_crisis_mod/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/ikseth/stellaris_cetana_fair_crisis_mod/releases/tag/v1.0.0
