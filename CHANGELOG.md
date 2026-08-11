# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project uses [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.2.1] - 2026-08-11

First release actually loaded by the game with the mod enabled in a playset.
The three defects below were found in that run's `error.log`.

### Fixed

- `cfc.1` was fired from the `crisis.8005` override with `country_event`, but it
  is declared as a scopeless `event`. The engine rejected the call, so detection
  at spawn was skipped and only the next monthly pulse installed the phase.
- `cfc_queen_reinforce` used `$CAP$` inside its log string. The macro
  preprocessor scans quoted text too and reported an invalid macro entry on
  every load.
- `cfc_wg_intervene_cetana` had no `GFX_cfc_wg_intervene_cetana` sprite, logged
  on every start. Added `interface/cfc_war_goals.gfx`, which references the
  vanilla diplomacy war texture by path.

### Added

- Validator checks for all three classes of defect: war goal icons, macro
  parameters inside log strings, and event fire scopes that disagree with the
  event's own declaration. Brace balancing now also covers `interface/`.

## [1.2.0] - 2026-08-11

### Added

- Conventional victory condition for Cetana. A Fallen/Awakened Empire is only
  removed after `cfc_fallen_empire_is_militarily_broken` has held for six
  consecutive months: it is at war with Cetana, has no operational mobile
  warfleet left, and Cetana holds space inside its borders. The vanilla system
  wipe is then reused for the removal, so `crisis.8043` and the normal Synthetic
  Queen chain remain reachable without any scripted head start.
- Independent AI intervention. Each AI empire rolls at most once per year during
  the Fallen Empire phase and may declare war on Cetana on its own, weighted by
  relative fleet power and ethics. No empire is ever enlisted by script.
- Deadlock guard. If a Fallen Empire leaves the war through a status quo peace
  and stays at peace for twelve months, the vanilla `wg_end_threat` war is
  declared again. Vanilla could never reach this state because its colony grind
  never stopped.

### Changed

- Cetana's reinforcements now diminish. Vanilla restored her to thirteen mobile
  fleets on every `crisis.8042` tick; the replacement chain restores 13, 11, 9,
  7, 5 and 3 fleets at yearly intervals and then stops, so a long war of
  attrition against her can be won.
- The player option in `crisis.8063` and the new AI decision share a single
  effect, so both grant exactly the same vanilla bypass flags.

### Fixed

- Cetana could no longer win the Fallen Empire phase at all. Removing the
  destructive `crisis.8042` branches also removed the only vanilla path to
  eliminating a Fallen Empire country, and `crisis.8043` requires that none
  exist. Without the new conquest condition the crisis could stall in that phase
  indefinitely.

## [1.1.0] - 2026-08-10

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

[Unreleased]: https://github.com/ikseth/stellaris_cetana_fair_crisis_mod/compare/v1.2.1...HEAD
[1.2.1]: https://github.com/ikseth/stellaris_cetana_fair_crisis_mod/compare/v1.2.0...v1.2.1
[1.2.0]: https://github.com/ikseth/stellaris_cetana_fair_crisis_mod/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/ikseth/stellaris_cetana_fair_crisis_mod/compare/v1.0.3...v1.1.0
[1.0.3]: https://github.com/ikseth/stellaris_cetana_fair_crisis_mod/compare/v1.0.2...v1.0.3
[1.0.2]: https://github.com/ikseth/stellaris_cetana_fair_crisis_mod/compare/v1.0.1...v1.0.2
[1.0.1]: https://github.com/ikseth/stellaris_cetana_fair_crisis_mod/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/ikseth/stellaris_cetana_fair_crisis_mod/releases/tag/v1.0.0
