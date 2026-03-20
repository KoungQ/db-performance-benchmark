#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCENARIOS_DIR="${SCENARIOS_DIR:-${SCRIPT_DIR}/../scenarios}"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../../../.." && pwd)"
RESULT_DIR="${1:-${SCRIPT_DIR}/../results/postgres}"
CLIENTS="${CLIENTS:-10}"
JOBS="${JOBS:-${CLIENTS}}"
TIME_SECONDS="${TIME_SECONDS:-300}"
WINDOW_SECONDS="${WINDOW_SECONDS:-5}"
SLEEP_BETWEEN="${SLEEP_BETWEEN:-0}"
POSTGRES_HOST="${POSTGRES_HOST:-127.0.0.1}"
POSTGRES_PORT="${POSTGRES_PORT:-5433}"
POSTGRES_USER="${POSTGRES_USER:-benchmark}"
POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-${BENCH_POSTGRES_PASSWORD:-benchmark}}"
POSTGRES_DB="${POSTGRES_DB:-db_benchmark}"
RUN_ID="${RUN_ID:-$(date +%Y%m%d-%H%M%S)}"
PUSH_METRICS="${PUSH_METRICS:-true}"
STREAM_SCRIPT="${ROOT_DIR}/scripts/stream-engine-metrics.sh"
DELETE_SCRIPT="${ROOT_DIR}/scripts/delete-engine-metrics.sh"
SCENARIOS="${SCENARIOS:-room-checklist-read room-checklist-insert room-checklist-update}"

mkdir -p "${RESULT_DIR}"

export PGPASSWORD="${POSTGRES_PASSWORD}"
PG_CONN="${PG_CONN:-postgresql://${POSTGRES_USER}@${POSTGRES_HOST}:${POSTGRES_PORT}/${POSTGRES_DB}}"

echo "PostgreSQL pgbench run id: ${RUN_ID}"
echo "PostgreSQL target: ${POSTGRES_HOST}:${POSTGRES_PORT}/${POSTGRES_DB}"
echo "Clients: ${CLIENTS}, jobs: ${JOBS}, duration: ${TIME_SECONDS}s, window: ${WINDOW_SECONDS}s"
echo ""

# Room-checklist scenarios (seed data must be loaded first)
for scenario in ${SCENARIOS}; do
  output_file="${RESULT_DIR}/${scenario}-${RUN_ID}.txt"
  : > "${output_file}"
  echo "=== Running ${scenario} ==="
  echo "Result file: ${output_file}"
  remaining="${TIME_SECONDS}"
  chunk=1
  while (( remaining > 0 )); do
    chunk_seconds="${WINDOW_SECONDS}"
    if (( remaining < chunk_seconds )); then
      chunk_seconds="${remaining}"
    fi

    echo "--- ${scenario} chunk ${chunk} (${chunk_seconds}s) ---" | tee -a "${output_file}"
    pgbench -n -c "${CLIENTS}" -j "${JOBS}" -T "${chunk_seconds}" \
      -f "${SCENARIOS_DIR}/${scenario}.sql" "${PG_CONN}" \
      | {
        if [[ "${PUSH_METRICS}" == "true" ]]; then
          bash "${STREAM_SCRIPT}" postgres "${scenario}" "${RUN_ID}" "${chunk}" "${output_file}"
        else
          tee -a "${output_file}"
        fi
      }

    remaining=$((remaining - chunk_seconds))
    chunk=$((chunk + 1))
  done
  if [[ "${PUSH_METRICS}" == "true" ]]; then
    bash "${DELETE_SCRIPT}" postgres "${scenario}" "${RUN_ID}" || true
  fi
  echo "Sleeping ${SLEEP_BETWEEN}s between scenarios..."
  sleep "${SLEEP_BETWEEN}"
done

echo "PostgreSQL pgbench run complete: ${RESULT_DIR}"
