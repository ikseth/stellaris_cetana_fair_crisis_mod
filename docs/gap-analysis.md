# Gap analysis after the first live test

## Executive finding

The first implementation correctly neutralized the two asymmetric damage
modifiers and most of the recursive `crisis.8042` weakener. It began its
normalization too late and assumed `crisis.8042` was the whole forced-victory
mechanism. Vanilla has two earlier expansion passes plus an initial spawn wipe,
all using `synth_queen_wipe_system`; these explain both observations from the
test.

There is also a decisive deployment finding: the inspected `2615.01.01` and
`2616.07.01` saves contain no `cfc_` flag, while the current launcher state in
`dlc_load.json` reports `"enabled_mods": []`. Those saves therefore did not run
the installed CFC scripts. This explains why even the mechanisms already
overridden in version 1.0.3 were still observed. Merely seeing the mod in the
launcher library is not the same as enabling it in the playset used to load the
save.

The saves provide positive evidence for the vanilla paths: they contain
`weaker_navy` and `synth_queen_storm`, proving that `crisis.8042` reached at
least its storm and fleet-weakening stages. They also contain
`synth_queen_failed_attack` and `synth_queen_shes_too_strong`, proving that a
default-empire battle invoked `crisis.8065`. This is stronger than inference
from the visual disappearance alone.

## Answers to the seven diagnostic questions

### 1. What removed the nanobot-marked Fallen Empire?

The direct cause was colony destruction, not a completed military war. Vanilla
`synth_queen_spawn` preferentially selects the xenophobe FE capital, otherwise
any non-machine FE capital. It calls `synth_queen_wipe_planet` and
`synth_queen_wipe_system`. Both use `destroy_colony`; the system wipe applies it
to every inhabited non-primitive planet in that system. If those are the
country's last colonies, normal country cleanup makes the FE disappear.

The same outcome can recur 360 and 720 days later. `crisis.8010` and
`crisis.8015` call `synth_queen_wipe_system` on neighbouring systems accepted by
`synth_queen_can_steal_system`. That trigger explicitly permits any non-default
owner, which includes both FE and AE territory.

### 2. Which file/event/effect did it?

- `events/machine_age_crisis_events.txt`: `crisis.8005`, `crisis.8010`,
  `crisis.8015`.
- `common/scripted_effects/02_machine_age_effects.txt`:
  `synth_queen_spawn`, `synth_queen_wipe_planet`,
  `synth_queen_wipe_system`.
- `common/scripted_triggers/02_scripted_triggers_machine_age.txt`:
  `synth_queen_can_steal_system`.

There is no separate country-kill command in this path. `destroy_colony` removes
the territorial basis and the engine subsequently removes a country with none
left. Functionally it is still scripted country elimination.

### 3. What really happened to the disappearing fleets?

There are three initial-phase paths, distinguishable by condition:

1. A fleet already in a system selected by spawn/expansion is processed inside
   `synth_queen_wipe_system`. Non-mobile stations are deleted. A regular FE
   fleet loses 62–99% hull per ship (with one random destroy branch) and is sent
   `mia_return_home`. An AE fleet matches the broader non-default/non-FE branch
   and is destroyed outright.
2. A fleet entering a `queen_scorn_storm` system triggers `crisis.8024` through
   `on_entering_system_fleet`. Its ships receive scripted damage/destruction and
   the fleet is sent MIA. The destroy outcome is weighted three times higher for
   FE/AE.
3. `crisis.8042` step 2 destroys 80% of the ships in a random mobile FE/AE
   fleet. This can happen far from an observed battle.

For the inspected test saves, `weaker_navy` proves that `crisis.8042` destroyed
the scripted 80% share of one selected FE/AE fleet. The same saves also show the
storm stage, so `crisis.8024` remains a possible cause for fleets that crossed
storm systems; the save format does not retain a per-ship event history that
would map every observed fleet to one command. The default empire's observed
failed attack is separately proven to be `crisis.8065`. These are scripted MIA
or destruction paths, not merely extremely fast combat.

### 4. Is there scripted fleet destruction?

Yes. Exact commands present in the initial chain include `delete_fleet`,
`destroy_fleet`, `destroy_ship`, `reduce_hp_percent`, and
`set_mia = mia_return_home`. They occur in `synth_queen_wipe_system`,
`crisis.8024`, and `crisis.8042`. `crisis.8065` contains a similar damage/MIA
path for default empires that attack before receiving a bypass flag.

### 5. Does protection, invulnerability, or non-hostility remain?

There is no invulnerability entry in `common/ship_sizes/26_synth_queen.txt`.
The Titan has very high vanilla hull/armor/shield values, strong damage/fire
rate and `never_mia = yes`, but it can be destroyed and vanilla watches exactly
that destruction in `crisis.23015`.

The practical protection is event-driven:

- `crisis.8024` prevents unprotected fleets from traversing Queen storm.
- `crisis.8065` undoes a default empire's premature attack unless the country
  has `synth_queen_cannot_yeet_the_fleets`.
- before the first speech the Queen is `synth_queen_storm`; after reveal she is
  `synth_queen`. Both country types allow diplomatic wars. Normal diplomacy is
  custom-routed, so the mod's explicit opt-in action remains the reliable UI.

The original normalizer granted storm protection only after the first speech,
so it did not protect FE/AE fleets from spawn or the first two expansion passes.

### 6. Which additional forced-victory mechanisms were initially missed?

- The FE-capital selection and immediate wipe inside `synth_queen_spawn`.
- The two timed wipe expansions in `crisis.8010` and `crisis.8015`.
- The AE-specific `destroy_fleet` fall-through in
  `synth_queen_wipe_system`.
- The FE scripted hull damage, ship destruction and MIA branch in the same
  effect.
- The fact that `crisis.8024` is already relevant before the first speech.
- `crisis.8042`'s first step adds more storm systems, not just fleet/planet
  damage.
- The current `crisis.8042` replacement also accidentally removed the vanilla
  `crisis.8050` Queen fleet top-up, which is not opponent destruction and should
  be retained to avoid globally weakening Cetana.

### 7. What did the current mod already correct correctly?

- Its `queen_combat_modifier` replacement removes Cetana's FE/AE `+200%`
  damage entries and reduces hull regeneration from 10% to 1%, while preserving
  speed, war exhaustion, bombardment and damage against other crisis types.
- Its neutral `beset_by_cetana` definition removes the FE/AE `-90%` anti-Cetana
  penalty; the normalizer also removes saved instances.
- Its `crisis.8042` override prevents the recursive 80% fleet purge and colony
  attacks, including calls already queued in a save.
- Its voluntary `crisis.8063` action does not declare war for uninvolved normal
  empires and grants the two relevant bypass flags.
- Its Titan detector uses `on_ship_destroyed_perp`, the same hook as vanilla,
  and delegates authoritative defeat/All Crises bookkeeping to
  `crisis.23015` instead of using `kill_country`.
- It leaves `crisis.8043` untouched for the Cetana-wins branch.

## Corrective scope

The correction must start at `crisis.8005`, intercept FE/AE system wipes in
`8010/8015`, normalize storm access before those events, and retain the benign
`crisis.8050` call in the `8042` override. No global override of
`synth_queen_wipe_system` is justified because later Cetana content legitimately
uses related wipe effects.

## Second review: gaps introduced by the correction itself

The 1.1.0 correction removed every forced-victory mechanism and stopped there.
Reading `crisis.8043` against what was left shows three problems that only
appear once the scripting is gone.

### 8. Cetana could no longer win the phase at all

`crisis.8043` fires only when `NOT = { any_country = { fallen_empire or
awakened_fallen_empire } }`. In vanilla, the sole mechanism that reaches that
state is `crisis.8042` step 3+, destroying one FE colony every 180 days. That is
precisely what the mod removed. Cetana has no entry in `common/armies`, so she
cannot invade; her only conventional route to a colony is armageddon bombardment
(`is_crisis_faction = yes` satisfies the stance trigger), which the AI may never
carry through against every FE world. The likely outcome was an FE phase that
never ends in either direction.

Resolved in 1.2.0 by `cfc.30`: the vanilla wipe is applied to one Fallen Empire
only after `cfc_fallen_empire_is_militarily_broken` has held for six consecutive
months. The removal is unchanged vanilla; its precondition is now a war result.

### 9. The war of attrition was one-sided against the Fallen Empires

`crisis.8050` restores Cetana to thirteen mobile fleets and vanilla called it on
every tick of the endless `crisis.8042` chain. The 1.1.0 override kept exactly
one call, which is neither the vanilla behaviour nor a neutral one: Fallen
Empires rebuild ships and Cetana would not, so the phase drifted towards her
defeat by default. Version 1.2.0 first replaced it with diminishing waves. Live
testing then showed that Cetana's initial forces and Titan were already strong
enough that even those finite replacements made player attrition disproportionate;
the current version disables all replacement and keeps `cfc.50` only as an inert
compatibility target for events serialized by older saves.

### 10. `wg_end_threat` permits status quo, and vanilla never noticed

`forbidden_peace_offers` in `wg_end_threat` blocks surrender and demanded
surrender but not `status_quo`. Vanilla was immune to the consequence because
its colony grind ran regardless of the war state. With the grind removed, an AI
Fallen Empire that peaces out freezes the crisis permanently. `cfc.30` now
re-declares the vanilla war after twelve months at peace.

### 11. Other empires could not join before the crisis proper

Only a human player could act, through the `crisis.8063` option, and only after
speech 1 — `synth_queen_storm` sets `show_in_contacts_list = no` and
`can_talk_to_the_synth_queen` is granted by `crisis.8040/8041`. AI empires had
no route at all: `cfc_wg_intervene_cetana` carries `ai_weight = 0` and the AI
does not declare war on crisis countries on its own. `cfc.40` gives every AI
empire one weighted roll per year during the phase.

### Confirmed as already correct

`crisis.23015` grants `r_cetanas_heart` with `add_relic` in root scope, and
`on_ship_destroyed_perp` binds root to the country that destroyed the ship. The
relic therefore already goes to whoever kills the Titan, Fallen Empire or normal
empire, without any mod intervention.
