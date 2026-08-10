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

## T1 — first Fallen Empire

1. Load immediately before Cetana appears.
2. Let `crisis.8005`, `8010`, and `8015` fire naturally.
3. Inspect the original FE capitals and the nanobot-marked frontier systems.

Expected: Cetana appears from a safe uncolonized bastille. No FE/AE colony or
country disappears from a scripted spawn/expansion wipe. Visual storm expansion
may still appear.

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

Expected: one vanilla-continuation log, then normal `crisis.8043`, speech 2,
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

## Additional regression checks

### R1 — late vanilla crisis

Let Cetana win T8 and later finish her crisis normally. Expected: projects,
convoys, raids, final war, rewards and cleanup match an unmodded 4.4.6 game.

### R2 — other crisis modifiers

Inspect `queen_combat_modifier` in debug tooltips. Expected: speed,
regeneration, war-exhaustion, bombardment and damage bonuses against AI,
extradimensional and swarm crises remain.

### R3 — error log

After every scenario, search `error.log` for `cfc`, overwritten crisis IDs,
invalid scopes, missing localization and unknown effects. Any such entry blocks
release even if the visible branch appears correct.

## Recommended restart point

For the next live test, load the last save **before `crisis.8005` fires and
before any FE capital receives `synth_queen_bastille` or `queen_scorn_storm`**.
That is the only point that exercises the corrected spawn and both expansion
passes. A save after the first FE was removed cannot validate T1 and cannot be
repaired losslessly.
