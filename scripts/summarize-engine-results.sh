#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
RESULT_ROOT="${ROOT_DIR}/benchmarks/engine/mysql-vs-postgres/results"

SCENARIOS=(
  room-checklist-read
  room-checklist-insert
  room-checklist-update
)

latest_file() {
  local dir="$1"
  local scenario="$2"

  ls -1t "${dir}/${scenario}"-*.txt 2>/dev/null | head -n 1
}

extract_mysql_tps() {
  sed -n 's/.*transactions:[[:space:]]*[0-9][0-9]*[[:space:]]*(\([0-9.][0-9.]*\) per sec.).*/\1/p' "$1" | head -n 1
}

extract_mysql_latency_ms() {
  sed -n 's/.*avg:[[:space:]]*\([0-9.][0-9.]*\).*/\1/p' "$1" | head -n 1
}

extract_postgres_tps() {
  sed -n 's/^tps = \([0-9.][0-9.]*\).*/\1/p' "$1" | head -n 1
}

extract_postgres_latency_ms() {
  sed -n 's/^latency average = \([0-9.][0-9.]*\) ms/\1/p' "$1" | head -n 1
}

print_row() {
  local scenario="$1"
  local mysql_file="$2"
  local postgres_file="$3"
  local mysql_tps="-"
  local mysql_latency="-"
  local postgres_tps="-"
  local postgres_latency="-"

  if [[ -n "${mysql_file}" ]]; then
    mysql_tps="$(extract_mysql_tps "${mysql_file}")"
    mysql_latency="$(extract_mysql_latency_ms "${mysql_file}")"
  fi

  if [[ -n "${postgres_file}" ]]; then
    postgres_tps="$(extract_postgres_tps "${postgres_file}")"
    postgres_latency="$(extract_postgres_latency_ms "${postgres_file}")"
  fi

  printf "%-26s | %12s | %14s | %12s | %14s\n" \
    "${scenario}" \
    "${mysql_tps:--}" \
    "${mysql_latency:--}" \
    "${postgres_tps:--}" \
    "${postgres_latency:--}"
}

echo "Engine benchmark summary"
echo "Metric units: throughput = transactions per second, processing time = average latency in ms"
echo ""
printf "%-26s | %12s | %14s | %12s | %14s\n" \
  "Scenario" \
  "MySQL TPS" \
  "MySQL Avg ms" \
  "Postgres TPS" \
  "Postgres Avg ms"
printf -- "%s\n" "-----------------------------------------------------------------------------------------------"

for scenario in "${SCENARIOS[@]}"; do
  mysql_file="$(latest_file "${RESULT_ROOT}/mysql" "${scenario}" || true)"
  postgres_file="$(latest_file "${RESULT_ROOT}/postgres" "${scenario}" || true)"
  print_row "${scenario}" "${mysql_file:-}" "${postgres_file:-}"
done

echo ""
echo "Source directories:"
echo "  ${RESULT_ROOT}/mysql"
echo "  ${RESULT_ROOT}/postgres"
