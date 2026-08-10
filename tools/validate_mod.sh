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
done < <(find "$repo_root/common" "$repo_root/events" -type f -name '*.txt' -print | sort)
note "Clausewitz script braces are balanced"

duplicate_cfc_ids=$(sed -nE 's/^[[:space:]]*id[[:space:]]*=[[:space:]]*(cfc\.[0-9]+).*/\1/p' \
	"$repo_root"/events/*.txt | sort | uniq -d)
if [[ -n $duplicate_cfc_ids ]]; then
	fail "duplicate CFC event IDs: $duplicate_cfc_ids"
else
	note "CFC event IDs are unique"
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
