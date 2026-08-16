# Fair Crisis test plan

## Test baseline and evidence

- Stellaris Pegasus 4.4.6 (fdde), The Machine Age enabled.
- Start with `-debug_mode` and preserve `game.log`, `error.log`, and the save
  from immediately before `crisis.8005`.
- Run once without console intervention where possible. If console assistance
  is used to force a branch, record every command with the result.
- For fleet-loss tests, pause before entry, record fleet size/power/system, run
  at slowest speed, and inspect both the battle report and CFC log transitions.
- Search logs for `[Cetana Fair Crisis]`; there should be no daily/monthly spam.

### Mandatory preflight

1. In the launcher's selected playset, verify that **Cetana Fair Crisis 1.3.0**
   is enabled, not merely present in the library.
2. After launch, verify that `dlc_load.json` lists
   `mod/cetana_fair_crisis.mod` under `enabled_mods`.
3. Load the pre-`crisis.8005` save and verify the first CFC detection logs after
   Cetana appears. If no `cfc_initial_phase_active` flag and no CFC log exists,
   stop: that run is unmodded and cannot validate any scenario below.

## T1 — first Fallen Empire

1. Load immediately before Cetana appears.
2. Let `crisis.8005`, `8010`, and `8015` fire naturally.
3. Inspect the original FE capitals and the nanobot-marked frontier systems.

Expected: Cetana appears from a safe uncolonized bastille (or the minimal CFC
fallback system in a completely occupied galaxy). No FE/AE colony or country
disappears from a scripted spawn/expansion wipe. Visual storm expansion may
still appear.

## T2 — FE fleet enters Cetana territory

1. Record the fleet composition immediately before entry.
2. Enter a Queen storm system and advance one day at a time.
3. Check whether a battle starts and whether a combat report is produced.

Expected: no `crisis.8024` scripted damage/MIA/destruction. Any loss corresponds
to actual combat. The one-shot fleet-interception log must already exist.

## T3 — FE attacks Cetana

Expected: both sides become hostile, weapons fire, and normal battle damage is
recorded. Cetana retains her general vanilla statistics but neither asymmetric
FE/AE damage modifier applies.

## T4 — FE defeats Cetana

1. Let an FE/AE destroy `synth_queen_titan` before speech 2.
2. Continue through `crisis.23015`, `23005`, and `23010`.

Expected: early-defeat, cleanup-invoked and crisis-completed logs; global
`synth_queen_defeated`; no Synthetic Queen doomclock/situation afterward; no
remaining initial FE storm/fog restrictions.

## T5 — player does not intervene

Close Cetana's pre-second-speech contact without choosing the CFC action.

Expected: no player-Cetana war. Only vanilla FE/AE participants fight her.

## T6 — player intervenes

Use **Intervene against Cetana** in `crisis.8063`.

Expected: only the player and normal diplomatic participants enter the CFC war;
the player's fleets cross storm and engage without `crisis.8065` sending them
MIA.

## T7 — player defeats Cetana

Destroy the Titan during the initial phase after T6.

Expected: identical authoritative defeat and cleanup to T4. The mod must not
invoke a second victory or directly kill the Queen country.

## T8 — Cetana defeats Fallen Empires

Do not intervene and let actual wars remove every FE/AE.

Expected: for each FE, six monthly steps of confirmed military collapse, then
the `lost the war against Cetana` log and its colonies destroyed. After the last
one, a single vanilla-continuation log, then normal `crisis.8043`, speech 2,
doomclock and player-facing Synthetic Queen situation. No CFC mechanics alter
the later crisis.

## T9 — All Crises

Use the **All Crises** setting and complete T4 or T7. Continue beyond the next
eligible crisis interval.

Expected: `crisis.23015` removes `galactic_crisis_recently_fired`, consumes the
appropriate early-defeat tracker, and another end-game crisis remains eligible.
`galactic_crisis_happened` may remain set as vanilla intends.

## T10 — existing save during initial war

1. Make a copy of a save with Cetana alive, speech 1 complete and FE/AE war in
   progress, then enable the corrected mod.
2. Load and wait at most one monthly pulse.

Expected: live `beset_by_cetana`, Queen storm/fog weakener state and fleet
protection are normalized; no duplicate Queen, war, speech, or timer. An FE
already destroyed before this save is not recreated.

## T11 — save/load/save/load

Save during Fair Crisis, reload at least three times, and advance two monthly
pulses after each load.

Expected: the same flags and number of wars/events remain. Each transition log
appears once; no modifiers, victory event, situation, or Queen country is
duplicated.

## T12 — collapse condition is reversible

1. Let an FE lose its whole navy while Cetana holds one of its systems.
2. Before the sixth month, console-spawn an FE warfleet or pull Cetana's fleets
   out of FE space.

Expected: no collapse log and no colony destroyed. `cfc_collapse_months` returns
to zero and the countdown restarts only when all four conditions hold again.
This is the test that distinguishes a war outcome from a timer.

## T13 — AI empires intervene on their own

Observe at least three in-game years of the FE phase with several strong AI
empires present.

Expected: occasional `declared war on Cetana during the FE phase` logs, at most
one roll per empire per year, and no roll at all from an empire whose fleet
power is below Cetana's. No AI empire is ever enlisted automatically, and none
of them is dragged in by the player's own intervention.

## T14 — no reinforcements

Destroy one of Cetana's initial mobile fleets and advance at least seven game
years.

Expected: the fleet is never replaced. A save with a legacy `cfc.50` event
already queued logs `Cetana reinforcements disabled` but creates no ships.

## T15 — Titan and war-exhaustion balance

Join the early war with a late-game coalition around 4M displayed fleet power,
then fight the Titan in friendly territory. Record both sides' fleet power and
war exhaustion before and after the battle.

Expected: the Titan remains a boss-scale target but is no longer displayed near
its old 7.36M value in a 1x crisis game. A prepared coalition can damage or
destroy it with heavy losses. The participant's war exhaustion does not rise.

## T16 — status quo peace does not freeze the crisis

Force or wait for a status quo peace between an FE and Cetana.

Expected: after twelve months at peace, one `Reopened the stalled Cetana war`
log and a fresh `wg_end_threat` war. The counter resets whenever the war is
active, so an ordinary war produces no such log.

## Additional regression checks

### R1 — late vanilla crisis

Let Cetana win T8 and later finish her crisis normally. Expected: projects,
convoys, raids, final war, rewards and cleanup match an unmodded 4.4.6 game.

### R2 — other crisis modifiers

Inspect `queen_combat_modifier` in debug tooltips. Expected: speed,
regeneration, war-exhaustion, bombardment and damage bonuses against AI,
extradimensional and swarm crises remain.

### R3 — error log

After every scenario, search `error.log` for `cfc`, invalid scopes, missing
localization and unknown effects. Any such entry blocks release even if the
visible branch appears correct. Two entry shapes are expected and benign:

- `an event with id [crisis.8005] already exists!` for each of the five
  overridden IDs. It confirms the CFC definition was registered first and the
  vanilla one discarded, which is how the override works.
- Vanilla `namelist.cpp` ship-name warnings, unrelated to this mod.

Everything else is a defect. The 1.2.0 run produced three that 1.2.1 fixes: a
`$CAP$` macro inside a log string, a war goal without a `GFX_` sprite, and
`cfc.1` fired as a country event from `crisis.8005`.

## Recommended restart point

For the next live test, load the last save **before `crisis.8005` fires and
before any FE capital receives `synth_queen_bastille` or `queen_scorn_storm`**.
That is the only point that exercises the corrected spawn and both expansion
passes. A save after the first FE was removed cannot validate T1 and cannot be
repaired losslessly.
