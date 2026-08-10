# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project uses [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

[Unreleased]: https://github.com/ikseth/stellaris_cetana_fair_crisis_mod/compare/v1.0.2...HEAD
[1.0.2]: https://github.com/ikseth/stellaris_cetana_fair_crisis_mod/compare/v1.0.1...v1.0.2
[1.0.1]: https://github.com/ikseth/stellaris_cetana_fair_crisis_mod/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/ikseth/stellaris_cetana_fair_crisis_mod/releases/tag/v1.0.0
