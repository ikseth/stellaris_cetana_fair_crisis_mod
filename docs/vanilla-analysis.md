# Vanilla analysis: Cetana

This document records the vanilla Stellaris scripts inspected while developing
Cetana Fair Crisis. It intentionally describes identifiers, responsibilities,
and integration points without reproducing complete copyrighted game files.

## Baseline

- Game: Stellaris **Pegasus 4.4.6 (fdde)**
- Steam build: **24109497**
- Launcher raw version: **v4.4.6**. Mod descriptors use `v4.4.*`; current
  launchers require the `v` prefix when evaluating `supported_version`.
- Required DLC: **The Machine Age** (`dlc032_machine_age`)
- Installation inspected: a standard Steam install of that version
  (`steamapps/common/Stellaris`)

All paths below are relative to that installation. Line numbers are omitted
because minor game updates can move definitions without changing their IDs.

## Files and identifiers inspected

### `events/machine_age_crisis_events.txt`

- `crisis.8005`: starts the crisis, sets `synth_queen_happened`, advances the
  crisis stage, and calls `synth_queen_spawn`.
- `crisis.8010` and `crisis.8015`: two 360-day expansion passes. Each calls
  `synth_queen_wipe_system` for eligible neighbouring systems.
- `crisis.8024`: intercepts fleets entering systems covered by
  `queen_scorn_storm`. Unprotected fleets are damaged, destroyed, or sent MIA;
  FE/AE fleets receive especially destructive handling.
- `crisis.8030`: completes the initial territorial setup, applies
  `beset_by_cetana` to FE/AE countries, and queues `crisis.8042`.
- `crisis.8040` and `crisis.8041`: first-contact paths. They establish
  communications, set the first-speech flags, and reveal the main Cetana
  country as type `synth_queen`.
- `crisis.8042`: vanilla FE weakener. It first creates storm effects, then
  removes most of a selected FE/AE fleet, and subsequently damages or destroys
  colonies while continually rescheduling itself.
- `crisis.8043`: transition to the normal Cetana situation. Its decisive
  condition is that no country of type `fallen_empire` or
  `awakened_fallen_empire` remains. It starts the doomclock and calls the second
  speech for playable countries.
- `crisis.8055`: custom-diplomacy gatekeeper used when contacting Cetana.
- `crisis.8063`: minimal pre-second-speech contact response. This is the point
  extended by the mod with voluntary intervention.
- `crisis.8065`: reacts when a normal empire attacks Cetana before vanilla says
  it is ready. Unless the required protection flags exist, it damages the
  attacking fleet and sends it MIA.
- `crisis.23015`: canonical Titan-destruction victory path. It destroys the
  doomclock, calls `end_crisis`, clears `galactic_crisis_recently_fired`, handles
  the early-defeat strength trackers, removes `synth_queen_ongoing`, sets
  `synth_queen_defeated`, and starts the final notification chain.
- `crisis.23005` and `crisis.23010`: final speech, removal of remaining Cetana
  country types, rewards, and post-crisis storm/modifier cleanup.

The corrected mod replaces only small event definitions by ID; it does not copy
or replace the complete Machine Age crisis event file. The exact override list
is maintained in the README and design document.

### `common/scripted_effects/02_machine_age_effects.txt`

- `synth_queen_spawn`: creates the Cetana species and country, initially as
  `synth_queen_storm`; preferentially selects a xenophobe or other non-machine
  FE capital; destroys the selected colony/system; applies
  `queen_combat_modifier`; saves both the local and global country event
  targets; creates the Titan and initial fleets.
- `synth_queen_wipe_planet`: marks the bastille and destroys its colony.
- `synth_queen_wipe_system`: destroys colonies, deletes stations, directly
  destroys AE and other non-default/non-FE fleets, damages/destroys FE/default
  ships and sends their fleet MIA, converts worlds and applies Queen storm.
- `synth_queen_fe_war`: makes each existing FE/AE declare a real event-driven
  war against `synth_queen_country_global`. It does not add normal empires.
- `synth_queen_scion_warning`: preserves the special Scion handling before the
  FE war begins.

These effects are not overridden. The mod adds separate, prefixed effects for
normalization and early-phase cleanup.

### `common/static_modifiers/22_static_modifiers_machine_age.txt`

- `queen_combat_modifier`: contains legitimate speed, regeneration, war
  exhaustion, bombardment, and anti-crisis bonuses, plus the two FE/AE-specific
  `+200%` damage entries.
- `beset_by_cetana`: applies `-90%` damage against the `synth_queen` country
  type.

The mod redefines these two keys. It omits the FE/AE-specific damage entries,
reduces the Queen-wide hull regeneration from 10% to 1%, preserves the other
properties, and makes the `beset_by_cetana` damage adjustment neutral.

### `common/country_types/00_country_types.txt`

The definitions inspected were `synth_queen_storm`, `synth_queen`,
`awakened_synth_queen`, `synth_queen_convoys`, and `synth_queen_outposts`.
Notably, `synth_queen` supports diplomatic wars and can receive the standard
declare-war action, while custom diplomacy routes normal contact through the
Cetana event UI. The mod does not replace country types.

### `common/war_goals/01_fallen_empire_war_goals.txt`

`wg_end_threat_synth_queen` is event-only in vanilla. The mod therefore defines
its own narrowly scoped containment war goal for the initial FE/AE phase rather
than changing the vanilla goal.

### `common/diplomatic_actions/00_actions.txt`

`action_declare_war` permits ordinary, Fallen, and Awakened Empires, subject to
available casus belli and war goals. Custom Cetana diplomacy makes a dedicated
event option the reliable UI entry point; no global automatic war is added.

### `common/on_actions/00_on_actions.txt`

- `on_entering_battle` invokes `crisis.8065`.
- `on_ship_destroyed_perp` invokes `crisis.23015` for the destroyed Cetana
  Titan.
- Game start, single-player save load, monthly pulse, and war-beginning hooks
  were reviewed for safe initialization and normalization.

The mod adds events to these on_actions in its own file. It does not replace the
vanilla on_actions file.

### `common/scripted_triggers/00_scripted_triggers.txt`

- `crisis_happened_and_defeated` recognizes Cetana as complete when both
  `synth_queen_happened` and `synth_queen_defeated` are set.
- `is_valid_end_threat_target` recognizes `synth_queen` as a containment target.

### `common/scripted_triggers/02_scripted_triggers_machine_age.txt`

`is_synth_queen_country_type` groups the main storm, normal, and awakened
Cetana country types. The mod uses vanilla country types but adds its own phase
trigger.

`synth_queen_can_steal_system` permits free systems, every non-default owner
(including FE/AE), and empty default-owned systems. It is the condition that
lets `crisis.8010/8015` feed FE/AE systems to the destructive wipe effect.

### `common/ship_sizes/26_synth_queen.txt`

`synth_queen_titan` has large vanilla hull/armor/shield values, damage and fire
rate bonuses, regeneration and `never_mia = yes`. It does not declare scripted
invulnerability. The mod does not replace its ship size or design.

### `common/situations/08_machine_age_situations.txt`

Contains `situation_synth_queen_doomclock` and
`situation_synth_queen_player_facing`. The mod does not replace either
situation. Preventing an invalid early transition is handled before these are
started.

### Crisis selection and All Crises files

The crisis scheduling and tracker references were reviewed in
`events/crisis_trigger_events.txt`, `events/crisis_events_1.txt`,
`events/crisis_events_2.txt`, and `events/crisis_events_3.txt`. The mod does not
override them. Instead, it deliberately delegates final victory to
`crisis.23015`, preserving its handling of `galactic_crisis_recently_fired`,
`galactic_crisis_early_defeat_tracker_1`, and
`galactic_crisis_early_defeat_tracker_2`.

## Mod integration points

| Vanilla key or hook | Mod behavior |
|---|---|
| `crisis.8005` | Selects an empty non-FE bastille candidate, then calls the full vanilla spawn effect. |
| `crisis.8010`, `crisis.8015` | Preserve timers/normal expansion; replace FE/AE wipes with visual storm only. |
| `queen_combat_modifier` | Removes FE/AE-specific damage bonuses and reduces hull regeneration from 10% to 1%. |
| `beset_by_cetana` | Neutralizes its damage penalty and removes live instances. |
| `crisis.8042` | Disables `crisis.8050`; replaces destructive/rescheduling behavior with one-shot cleanup. |
| `crisis.8063` | Adds voluntary intervention while retaining the vanilla close option. |
| `on_war_beginning` | Grants bypass flags only to countries actually fighting Cetana. |
| `on_ship_destroyed_perp` | Detects an early Titan loss and prepares safe cleanup. |
| `crisis.23015` | Left untouched as the authoritative victory and All Crises path. |
| `crisis.8043` | Left untouched as the authoritative transition when Cetana wins. |

## Copyright boundary

No complete vanilla Stellaris files, art, audio, localization catalogs, or other
game assets are included in this repository. The repository contains original
mod scripts and only the small replacement definitions necessary for the
Clausewitz/Jomini override mechanism. Vanilla behavior is summarized here in
original prose rather than reproduced as source code.
