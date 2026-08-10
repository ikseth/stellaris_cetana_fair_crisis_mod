# Cetana Fair Crisis: design specification

## Scope and invariant

This document is the implementation contract for Stellaris **Pegasus 4.4.6
(fdde)**. The invariant is deliberately narrow:

> During Cetana's initial conflict with Fallen and Awakened Empires, military
> combat alone decides whether Cetana reaches her normal Synthetic Queen phase.

The mod does not rebalance Cetana globally. If she wins the fair initial war,
vanilla resumes at `crisis.8043`. If her Titan is destroyed first, vanilla
`crisis.23015` remains the authority that ends the crisis.

## Vanilla state machine

```text
end-game selector
  |
  | crisis.8005 (sets synth_queen_happened, stage 1)
  v
synth_queen_spawn
  | chooses an FE capital preferentially
  | synth_queen_wipe_planet + synth_queen_wipe_system
  | creates synth_queen_storm country, Titan and six war fleets
  | schedules crisis.8010 +360d
  v
crisis.8010 -- expansion pass 1
  | every eligible neighbouring system -> synth_queen_wipe_system
  | schedules crisis.8015 +360d
  v
crisis.8015 -- expansion pass 2
  | every eligible neighbouring system -> synth_queen_wipe_system
  | schedules crisis.8030 +360d
  v
crisis.8030 -- stage 2
  | creates missing Queen bases
  | queues crisis.8039 for default/FE/AE countries
  | applies beset_by_cetana to FE/AE
  | queues crisis.8042 for each FE/AE
  | sets synth_queen_revenge_done
  v
crisis.8039 -> crisis.8040 (player) / crisis.8041 (AI)
  | sets synth_queen_ongoing, galactic_crisis_happened,
  | synth_queen_speech_1_happened and per-country speech_1
  | changes the Queen country to synth_queen
  | synth_queen_scion_warning -> synth_queen_fe_war
  v
real wg_end_threat wars: every FE/AE -> Cetana
  |
  | concurrently crisis.8042 repeatedly weakens FE/AE and crisis.8050
  | tops Cetana up to 13 mobile fleets
  v
on_yearly_pulse -> crisis.8043 when no FE/AE country exists
  | sets synth_queen_speech_2_happened
  | starts situation_synth_queen_doomclock
  | crisis.8044 / crisis.8045 second speech
  v
normal Synthetic Queen situation, research, raids and final war
  |
  | Titan destruction -> on_ship_destroyed_perp -> crisis.23015
  v
end_crisis, synth_queen_defeated, crisis.23005/23010 cleanup
```

`crisis.8024` runs independently from `on_entering_system_fleet` whenever a
fleet enters `queen_scorn_storm`. `crisis.8065` runs from
`on_entering_battle` when a default empire attacks Cetana before vanilla has
granted its bypass flag.

## Forced-victory mechanisms

| Class | Vanilla mechanism | Exact effect during the initial phase |
|---|---|---|
| COUNTRY DESTRUCTION | `synth_queen_spawn` -> `synth_queen_wipe_planet` / `synth_queen_wipe_system` | Preferentially targets an FE capital, destroys every colony in the system and can leave the FE with no colonies. |
| COUNTRY DESTRUCTION / PLANET EFFECT | `crisis.8010`, `crisis.8015` -> `synth_queen_wipe_system` | `synth_queen_can_steal_system` admits every non-default owner, including FE/AE. All non-primitive colonies in the selected system are destroyed. |
| FLEET DESTRUCTION | `synth_queen_wipe_system` | Deletes stations; destroys fleets whose owner is neither `default` nor `fallen_empire` (therefore including `awakened_fallen_empire`); damages/destroys FE ships and sends the fleet MIA. |
| FLEET DAMAGE | `crisis.8024` | Damages or destroys every ship entering Queen storm and sends the fleet MIA; the destroy branch has triple weight for FE/AE. |
| DAMAGE MODIFIER | `queen_combat_modifier` | Gives Cetana `+200%` damage against both FE and AE types. |
| DAMAGE MODIFIER | `beset_by_cetana` | Gives its FE/AE owner `-90%` damage against the `synth_queen` country type. |
| FLEET DESTRUCTION | `crisis.8042`, step 2 | Destroys 80% of the ships in a randomly selected mobile FE/AE fleet. |
| PLANET EFFECT / COUNTRY DESTRUCTION | `crisis.8042`, step 3+ | Repeatedly destroys non-capital colonies; devastates capitals and kills population groups. |
| OTHER | `crisis.8042` -> `crisis.8050` | Tops Cetana up to 13 mobile fleets. This is vanilla force composition, not direct removal of an opponent, and is retained. |
| DIPLOMATIC RESTRICTION / FLEET DAMAGE | `crisis.8065` | Damages/destroys an attacking default empire's fleet and sends it MIA unless it has the vanilla bypass flag. |
| WAR SCRIPTING | `synth_queen_fe_war` | Starts real FE/AE wars against Cetana. This is required and retained; it does not enlist normal empires. |
| INVULNERABILITY | none in `synth_queen_titan` or the main Queen country types | The Titan has enormous vanilla statistics and `never_mia`, but no scripted invulnerability. Its destruction is a valid vanilla defeat trigger. |

The later `synth_queen_mini_wipe_system` and game-over events are outside the
initial FE phase and remain untouched.

## Mod intervention matrix

| Vanilla mechanism | Decision | Reason | Implementation |
|---|---|---|---|
| `crisis.8005` + `synth_queen_spawn` | modify narrowly | Preserve the full spawn but prevent its preferential FE-capital sacrifice. | Small event override prepares a safe, uncolonized bastille candidate, calls the original effect, then starts Fair Crisis normalization. |
| `crisis.8010` / `crisis.8015` | modify narrowly | Their call to the global wipe effect destroys FE/AE colonies and fleets. | Small event overrides retain timers and normal expansion; FE/AE systems receive only the visual storm marker. |
| `synth_queen_wipe_system` | preserve | Used by later vanilla content and safe initial targets; a global override would be broad and incompatible. | Calls are intercepted only at initial-phase callers. |
| `queen_combat_modifier` | modify | Remove only the two FE/AE-specific damage entries. | Key-level static modifier override preserving all other entries. |
| `beset_by_cetana` | modify | Remove only the anti-Cetana damage penalty. | Neutral key-level override plus removal of live instances. |
| `crisis.8024` | preserve, bypass for FE/AE | It remains valid outside the fair war and for unprepared normal empires. | FE/AE receive `protected_from_queen_storm` before any expansion can affect them. |
| `crisis.8042` | modify narrowly | Its recursive storm, fleet and colony branches force Cetana's victory. | Override retains only `crisis.8050`, state normalization and one-shot logging; it does not reschedule itself. |
| `crisis.8065` | preserve, bypass volunteers | Normal empires must opt in, but their real battle must not be undone. | Voluntary participants get `synth_queen_cannot_yeet_the_fleets` and storm protection. |
| `synth_queen_fe_war` | preserve | Supplies the real initial wars required by the design. | No override. |
| `crisis.8043` | preserve | Authoritative vanilla continuation after military FE/AE elimination. | Log the transition and stop intervening after speech 2. |
| `crisis.23015` | preserve | Authoritative defeat, `end_crisis` and All Crises bookkeeping. | Early Titan detector blocks the 8043 race, performs initial-state cleanup, and lets vanilla 23015 execute. |

## Fair Crisis state machine

```text
crisis.8005
  |
  | safe non-FE bastille target; vanilla spawn otherwise unchanged
  v
CFC INITIAL / EXPANSION
  | FE/AE storm protection installed immediately
  | expansion may display nanites but cannot wipe FE/AE systems
  v
FIRST SPEECH + VANILLA FE/AE WARS
  | no FE/AE damage handicap
  | no Queen FE/AE-specific damage bonus
  | no scripted fleet/colony destruction
  | optional player intervention only
  |
  +---------------------------+
  |                           |
  | all FE/AE eliminated      | Cetana Titan destroyed
  | through actual war        | by FE/AE or volunteer
  v                           v
crisis.8043 vanilla           CFC early-defeat guard
Synthetic Queen chain         |
CFC stops intervening         v
                              crisis.23015 vanilla
                              end_crisis + All Crises state
                              crisis.23005/23010 cleanup
```

## Save migration and idempotence

| Loaded state | Action |
|---|---|
| Before Cetana | No mutation; the monthly/on-load event remains dormant. |
| `synth_queen_storm` exists before speech 1 | Detect immediately, protect every live FE/AE, remove live combat penalties/storm state, and mark the CFC phase once. No spawn or timer is repeated. |
| First speech / FE war active | Same normalization; voluntary participants already at war receive the two bypass flags. |
| An FE/AE was already script-destroyed | It is not recreated. Load an earlier save for a fair result. |
| `synth_queen_speech_2_happened` and no early-defeat guard | Log vanilla continuation once, remove the CFC active marker, and do not roll back the crisis. |
| Titan destroyed during the initial phase | Set an idempotent pending flag, block `crisis.8043`, clean only CFC/initial FE state, and wait for vanilla `synth_queen_defeated`. |
| `synth_queen_defeated` already set | Complete residual CFC cleanup once; never call the defeat event twice. |

All persistent mod flags use the `cfc_` prefix. Repeated load and monthly events
are guards/normalizers: they do not create Cetana, declare FE wars, restart
timers, or invoke victory.

## Engine boundary

Stellaris script cannot cancel a specific already queued country event. The
safe interception pattern is therefore to replace the small target event by
ID. An old save that already queued `crisis.8042` will call the harmless CFC
replacement. The same limitation makes restoration of an already destroyed FE
unsafe: its original pops, leaders, fleets, diplomacy and event scopes cannot be
reconstructed losslessly.
