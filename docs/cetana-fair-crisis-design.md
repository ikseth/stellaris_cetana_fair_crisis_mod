# Cetana Fair Crisis: design specification

## Scope and invariant

This document is the implementation contract for Stellaris **Pegasus 4.4.6
(fdde)**. The invariant is deliberately narrow:

> During Cetana's initial conflict with Fallen and Awakened Empires, military
> combat alone decides whether Cetana reaches her normal Synthetic Queen phase.

The invariant cuts both ways. Neutralizing vanilla's forced-victory scripting is
only half of it: the phase must still be able to *end*, and it must be able to
end either way. Cetana therefore keeps a conventional path to eliminating a
Fallen Empire, gated on an actual military outcome. Her initial fleets are
finite and her Titan remains boss-scale without being a practical invulnerability.

The mod narrowly rebalances Cetana's Titan. If she wins the fair initial war,
vanilla resumes at `crisis.8043`. If her Titan is destroyed first, vanilla
`crisis.23015` remains the authority that ends the crisis and grants
`r_cetanas_heart` to whoever destroyed it.

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
| REINFORCEMENT | `crisis.8042` -> `crisis.8050` | Repeatedly tops Cetana up to 13 mobile fleets, making combat losses non-persistent. |
| DIPLOMATIC RESTRICTION / FLEET DAMAGE | `crisis.8065` | Damages/destroys an attacking default empire's fleet and sends it MIA unless it has the vanilla bypass flag. |
| WAR SCRIPTING | `synth_queen_fe_war` | Starts real FE/AE wars against Cetana. This is required and retained; it does not enlist normal empires. |
| PRACTICAL INVULNERABILITY | `synth_queen_titan` | No literal invulnerability flag exists, but 1.75M hull, 1.25M armor, 500k shields, +200% damage, +300% fire rate and regeneration produced a 7.36M Titan in the inspected 1x save. |

The later `synth_queen_mini_wipe_system` and game-over events are outside the
initial FE phase and remain untouched.

## Mod intervention matrix

| Vanilla mechanism | Decision | Reason | Implementation |
|---|---|---|---|
| `crisis.8005` + `synth_queen_spawn` | modify narrowly | Preserve the full spawn but prevent its preferential FE-capital sacrifice. | Small event override prepares a safe, uncolonized bastille candidate, creates a minimal isolated fallback system only if necessary, calls the original effect, then starts Fair Crisis normalization. |
| `crisis.8010` / `crisis.8015` | modify narrowly | Their call to the global wipe effect destroys FE/AE colonies and fleets. | Small event overrides retain timers and normal expansion; FE/AE systems receive only the visual storm marker. |
| `synth_queen_wipe_system` | preserve | Used by later vanilla content and safe initial targets; a global override would be broad and incompatible. | Calls are intercepted only at initial-phase callers. |
| `queen_combat_modifier` | modify | Remove the two FE/AE-specific damage entries and prevent 10% hull regeneration from erasing combat progress. | Key-level static modifier override with 1% hull regeneration; other entries remain. |
| `beset_by_cetana` | modify | Remove only the anti-Cetana damage penalty. | Neutral key-level override plus removal of live instances. |
| `synth_queen_titan` | modify | Its vanilla concentration of offense and defense makes the newly enabled early war practically unwinnable. | Preserve the complete boss ship definition while reducing only hull, armor, shields, damage, fire rate and shield regeneration. |
| `crisis.8024` | preserve, bypass for FE/AE | It remains valid outside the fair war and for unprepared normal empires. | FE/AE receive `protected_from_queen_storm` before any expansion can affect them. |
| `crisis.8042` | modify narrowly | Its recursive storm, fleet, colony and reinforcement branches force Cetana's victory. | Override normalizes state, marks reinforcements exhausted and does not reschedule itself. |
| `crisis.8050` / `cfc.50` | disable during this phase | Any top-up devalues a military victory against already powerful initial fleets. | No new event is scheduled; legacy `cfc.50` events remain valid but create nothing. |
| `crisis.8065` | preserve, bypass volunteers | Normal empires must opt in, but their real battle must not be undone. | Voluntary participants, player or AI, get `synth_queen_cannot_yeet_the_fleets` and storm protection. |
| `synth_queen_fe_war` | preserve, re-arm | Supplies the real initial wars required by the design. | No override. `cfc.30` re-declares the same `wg_end_threat` war if a status quo peace stalls the phase. |
| FE/AE elimination | replace mechanism | Vanilla removed FE countries on a timer; Cetana has no armies to do it conventionally. | `cfc.30` applies the vanilla wipe only after six months of confirmed military collapse. |
| normal-empire hostility | extend | Vanilla never lets another empire fight Cetana this early, and the AI never declares war on a crisis country by itself. | Player option in `crisis.8063`; `cfc.40` yearly AI roll weighted by relative fleet power and ethics. |
| participant war exhaustion | suppress | An existential crisis war must not punish the defender like an ordinary territorial war. | The intervention war goal has `war_exhaustion = 0`; FE/AE countries using vanilla `wg_end_threat` receive a phase-scoped modifier. |
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
  | finite initial Queen fleets; no replacements
  | balanced boss Titan; no participant war exhaustion
  | cfc.40 yearly AI intervention roll / crisis.8063 player option
  | cfc.30 per-FE monthly evaluation
  |    +-- status quo peace held 12 months -> wg_end_threat redeclared
  |    +-- FE militarily broken 6 months   -> vanilla system wipe on that FE
  |
  +---------------------------+
  |                           |
  | all FE/AE eliminated      | Cetana Titan destroyed
  | through actual war        | by FE/AE, AI empire or player
  v                           v
crisis.8043 vanilla           CFC early-defeat guard
Synthetic Queen chain         |
CFC stops intervening         v
                              crisis.23015 vanilla
                              end_crisis + r_cetanas_heart to the killer
                              crisis.23005/23010 cleanup
```

## Conventional victory condition

Vanilla eliminated Fallen Empires only through `crisis.8042` step 3+, which
destroyed one colony every 180 days until the country had none left. That is the
mechanism the fair-war invariant forbids, and it is also the only vanilla path
to the `crisis.8043` precondition (`NOT = { any_country = { FE or AE } }`).
Cetana has no armies in `common/armies`, so she cannot take a colony by
invasion; leaving the gap open would let the crisis stall in the FE phase
forever.

`cfc_fallen_empire_is_militarily_broken` therefore expresses the same outcome as
a war result instead of a timer. All four conditions must hold simultaneously:

| Condition | Meaning |
|---|---|
| country type is `fallen_empire` or `awakened_fallen_empire` | scope guard |
| `is_at_war_with` Cetana | the removal can only follow from a live war |
| no owned mobile, non-civilian fleet above 5000 fleet power | its navy is gone |
| a Cetana mobile fleet inside `any_system_within_border` | she holds its space |

`cfc.30` increments `cfc_collapse_months` per monthly pulse while all of them
hold and resets it to zero the moment any of them stops. At six the vanilla
`synth_queen_wipe_system` runs over that country's systems, exactly the endpoint
vanilla reached, and the engine removes the colony-less country. A rebuilt FE
fleet or a Cetana withdrawal resets the counter and cancels the collapse.

The same event carries the deadlock guard. `wg_end_threat` forbids surrender but
permits status quo, so an AI Fallen Empire can now leave the war — impossible in
vanilla, where the grind continued regardless. Twelve consecutive months at
peace re-declare the vanilla war.

## Reinforcements

`crisis.8050` restored Cetana to thirteen mobile fleets from every tick of the
endless `crisis.8042` chain. Fair Crisis now disables that call completely.
Cetana keeps every initial fleet, but destroyed fleets stay destroyed. `cfc.50`
remains defined only so an event already serialized by an older version can
terminate harmlessly.

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
| Any state with live Fallen Empires | `cfc_collapse_months` and `cfc_peace_months` are created once per country by the normalizer, before `cfc.30` can read them. A 25-day flag keeps repeated loads from advancing either counter faster than one step per month. |
| `crisis.8042` or `cfc.50` already queued in an older save | Mark reinforcements exhausted; create no ships and schedule no further wave. |

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

The safe-spawn selector first reuses a colony-free, non-FE/AE system. If none
exists, `cfc_safe_bastille_system` is spawned at the rim and consumed by the
otherwise unchanged vanilla spawn effect. If even engine placement of that
system fails, the mod logs an error and refuses to call the FE-destructive
fallback; preserving the fair-war invariant takes precedence over advancing a
pathological broken spawn.
