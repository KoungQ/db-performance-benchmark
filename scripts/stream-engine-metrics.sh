#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 5 ]]; then
  echo "Usage: stream-engine-metrics.sh <mysql|postgres> <scenario> <run_id> <chunk-id> <result-file>"
  exit 1
fi

DATABASE="$1"
SCENARIO="$2"
RUN_ID="$3"
CHUNK_ID="$4"
RESULT_FILE="$5"
PUSH_SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/push-engine-metrics.sh"
TMP_FILE="$(mktemp)"

while IFS= read -r line; do
  printf "%s\n" "${line}" | tee -a "${RESULT_FILE}" >> "${TMP_FILE}"
done

case "${DATABASE}" in
  mysql)
    throughput="$(sed -n 's/.*transactions:[[:space:]]*[0-9][0-9]*[[:space:]]*(\([0-9.][0-9.]*\) per sec.).*/\1/p' "${TMP_FILE}" | tail -n 1)"
    latency_ms="$(sed -n 's/.*avg:[[:space:]]*\([0-9.][0-9.]*\).*/\1/p' "${TMP_FILE}" | tail -n 1)"
    ;;
  postgres)
    throughput="$(sed -n 's/^tps = \([0-9.][0-9.]*\).*/\1/p' "${TMP_FILE}" | tail -n 1)"
    latency_ms="$(sed -n 's/^latency average = \([0-9.][0-9.]*\) ms/\1/p' "${TMP_FILE}" | tail -n 1)"
    ;;
  *)
    echo "Unsupported database: ${DATABASE}"
    rm -f "${TMP_FILE}"
    exit 1
    ;;
esac

if [[ -n "${throughput:-}" && -n "${latency_ms:-}" ]]; then
  bash "${PUSH_SCRIPT}" "${DATABASE}" "${SCENARIO}" "${RUN_ID}" "${throughput}" "${latency_ms}" || true
else
  echo "Skipping Pushgateway update for ${DATABASE}/${SCENARIO}/${CHUNK_ID}. Could not parse metrics." >&2
fi

rm -f "${TMP_FILE}"
