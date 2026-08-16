#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
vanilla_root=${1:-}
failures=0

search_quiet() {
	local pattern=$1
	shift
	if command -v rg >/dev/null 2>&1; then
		rg -q -- "$pattern" "$@"
	else
		grep -E -q -- "$pattern" "$@"
	fi
}

search_recursive() {
	local pattern=$1
	shift
	if command -v rg >/dev/null 2>&1; then
		rg -n -- "$pattern" "$@"
	else
		grep -R -n -E -- "$pattern" "$@"
	fi
}

fail() {
	printf 'FAIL: %s\n' "$*" >&2
	failures=$((failures + 1))
}

note() {
	printf 'OK: %s\n' "$*"
}

while IFS= read -r script; do
	if ! awk '
		BEGIN { depth = 0 }
		{
			line = $0
			sub(/#.*/, "", line)
			depth += gsub(/{/, "{", line)
			depth -= gsub(/}/, "}", line)
			if (depth < 0) exit 2
		}
		END { if (depth != 0) exit 3 }
	' "$script"; then
		fail "unbalanced braces: ${script#"$repo_root"/}"
	fi
done < <(find "$repo_root/common" "$repo_root/events" "$repo_root/interface" \
	-type f \( -name '*.txt' -o -name '*.gfx' \) -print | sort)
note "Clausewitz script braces are balanced"

while IFS= read -r war_goal; do
	key=${war_goal##*/}
	key=${key%.txt}
	while IFS= read -r declared; do
		if ! search_quiet "name[[:space:]]*=[[:space:]]*\"GFX_$declared\"" "$repo_root"/interface/*.gfx; then
			fail "war goal $declared has no GFX_$declared sprite"
		fi
	done < <(sed -nE 's/^([a-z_][a-z0-9_]*)[[:space:]]*=[[:space:]]*\{.*/\1/p' "$war_goal")
done < <(find "$repo_root/common/war_goals" -type f -name '*.txt' -print | sort)
note "war goal icons declared"

duplicate_cfc_ids=$(sed -nE 's/^[[:space:]]*id[[:space:]]*=[[:space:]]*(cfc\.[0-9]+).*/\1/p' \
	"$repo_root"/events/*.txt | sort | uniq -d)
if [[ -n $duplicate_cfc_ids ]]; then
	fail "duplicate CFC event IDs: $duplicate_cfc_ids"
else
	note "CFC event IDs are unique"
fi

# The macro preprocessor also scans quoted text, so a $PARAM$ inside a log
# string is reported as an invalid macro entry at load time.
if search_recursive '^[[:space:]]*log[[:space:]]*=[[:space:]]*".*\$.*\$.*"' \
	"$repo_root/common" "$repo_root/events"; then
	fail "log string contains a macro parameter"
else
	note "log strings are macro-free"
fi

# Firing a scopeless event with country_event (or the reverse) is accepted by
# the parser and only fails at runtime, silently skipping the event.
declarations=$(awk '
	/^[[:space:]]*(country_)?event[[:space:]]*=[[:space:]]*\{/ {
		kind = ($0 ~ /country_event/) ? "country" : "scopeless"
	}
	/^[[:space:]]*id[[:space:]]*=[[:space:]]*cfc\./ {
		id = $3
		print kind, id
	}
' "$repo_root"/events/*.txt)
while IFS= read -r reference; do
	kind=${reference%% *}
	id=${reference##* }
	declared=$(printf '%s\n' "$declarations" | awk -v want="$id" '$2 == want { print $1 }')
	if [[ -n $declared && $declared != "$kind" ]]; then
		fail "$id is declared as a $declared event but fired as a $kind event"
	fi
done < <(sed -nE 's/^[[:space:]]*(country_)?event[[:space:]]*=[[:space:]]*\{[[:space:]]*id[[:space:]]*=[[:space:]]*(cfc\.[0-9]+).*/\1\2/p' \
	"$repo_root"/events/*.txt "$repo_root"/common/*/*.txt \
	| sed -E 's/^country_/country /; s/^cfc/scopeless cfc/')
note "CFC event fire scopes match their declarations"

# `event = { id = ... }` is not a valid effect in country scope even when the
# target itself is declared as a scopeless event. Let an on_action fire it.
if search_recursive '^[[:space:]]*event[[:space:]]*=[[:space:]]*\{[[:space:]]*id[[:space:]]*=' \
	"$repo_root/common" "$repo_root/events"; then
	fail "invalid generic event firing effect"
else
	note "no invalid generic event firing effects"
fi

actual_overrides=$(sed -nE 's/^[[:space:]]*id[[:space:]]*=[[:space:]]*(crisis\.[0-9]+).*/\1/p' \
	"$repo_root/events/cfc_vanilla_overrides.txt" | sort | tr '\n' ' ')
expected_overrides='crisis.8005 crisis.8010 crisis.8015 crisis.8042 crisis.8063 '
if [[ $actual_overrides != "$expected_overrides" ]]; then
	fail "unexpected vanilla event override set: $actual_overrides"
else
	note "vanilla event override allow-list matches"
fi

if search_recursive '(^|[[:space:]])(destroy_country|kill_country|destroy_colony|destroy_fleet|delete_fleet|destroy_ship|reduce_hp_percent|set_mia)[[:space:]]*=' \
	"$repo_root/common" "$repo_root/events"; then
	fail "destructive fleet/country/colony effect present in mod scripts"
else
note "no direct destructive fleet/country/colony effects"

if search_recursive 'synth_queen_create_war_fleet[[:space:]]*=' \
	"$repo_root/common" "$repo_root/events"; then
	fail "Cetana reinforcement creation is still reachable"
else
	note "Cetana reinforcement creation is disabled"
fi

if ! search_quiet '^[[:space:]]*war_exhaustion[[:space:]]*=[[:space:]]*0$' \
	"$repo_root/common/war_goals/cfc_cetana_war_goal.txt"; then
	fail "Cetana intervention war still generates war exhaustion"
else
	note "Cetana intervention war exhaustion is disabled"
fi

for expected_titan_value in \
	'max_hitpoints = 1000000' \
	'ship_armor_add = 650000' \
	'ship_shield_add = 300000' \
	'ship_weapon_damage = 0.5' \
	'ship_fire_rate_mult = 1' \
	'ship_shield_regen_add_perc = 0.02'; do
	if ! search_quiet "^[[:space:]]*$expected_titan_value$" \
		"$repo_root/common/ship_sizes/cfc_synth_queen_titan.txt"; then
		fail "missing Titan balance value: $expected_titan_value"
	fi
done
note "Cetana Titan balance values checked"

if ! search_quiet '^[[:space:]]*ship_hull_regen_add_perc[[:space:]]*=[[:space:]]*0\.01$' \
	"$repo_root/common/static_modifiers/cfc_queen_combat_modifiers.txt"; then
	fail "Cetana global hull regeneration is not balanced"
else
	note "Cetana global hull regeneration checked"
fi
fi

while IFS= read -r localization; do
	if [[ $(od -An -tx1 -N3 "$localization" | tr -d ' \n') != efbbbf ]]; then
		fail "localization lacks UTF-8 BOM: ${localization#"$repo_root"/}"
	fi
done < <(find "$repo_root/localisation" -type f -name '*.yml' -print | sort)
note "localization BOM check completed"

for descriptor in "$repo_root/descriptor.mod" "$repo_root/cetana_fair_crisis.mod"; do
	if ! search_quiet '^supported_version="v4\.4\.\*"$' "$descriptor"; then
		fail "wrong supported_version in ${descriptor#"$repo_root"/}"
	fi
done
note "descriptor compatibility markers checked"

while IFS= read -r oversized; do
	fail "suspiciously large script (possible full vanilla copy): ${oversized#"$repo_root"/}"
done < <(find "$repo_root/common" "$repo_root/events" -type f -size +200k -print)
note "repository copyright-size guard checked"

if [[ -n $vanilla_root ]]; then
	if [[ ! -d $vanilla_root/events || ! -d $vanilla_root/common ]]; then
		fail "invalid vanilla root: $vanilla_root"
	else
		vanilla_events="$vanilla_root/events/machine_age_crisis_events.txt"
		for event_id in crisis.8005 crisis.8010 crisis.8015 crisis.8042 crisis.8063 crisis.23015; do
			if ! search_quiet "id[[:space:]]*=[[:space:]]*$event_id([^0-9]|$)" "$vanilla_events"; then
				fail "missing vanilla event $event_id"
			fi
		done
		for effect_id in synth_queen_spawn synth_queen_wipe_planet synth_queen_wipe_system synth_queen_fe_war; do
			if ! search_quiet "^$effect_id[[:space:]]*=" "$vanilla_root/common/scripted_effects/02_machine_age_effects.txt"; then
				fail "missing vanilla effect $effect_id"
			fi
		done
		note "vanilla 4.4 integration identifiers checked"
	fi
fi

if (( failures > 0 )); then
	printf '%d validation failure(s)\n' "$failures" >&2
	exit 1
fi

printf 'Cetana Fair Crisis static validation passed.\n'
