#!/usr/bin/env bash
# Usage: run-api-bench.sh [mysql|postgres] [read-heavy|write-heavy|update-heavy] [repeat]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SCENARIO="${2:-read-heavy}"
TARGET="${1:-mysql}"
REPEAT="${3:-1}"
RESULT_DIR="${ROOT_DIR}/benchmarks/engine/mysql-vs-postgres/results/k6/${TARGET}"

case "${TARGET}" in
  mysql)
    BASE_URL="${BASE_URL:-http://127.0.0.1:8090}"
    ;;
  postgres)
    BASE_URL="${BASE_URL:-http://127.0.0.1:8091}"
    ;;
  *)
    echo "Unsupported target: ${TARGET}"
    exit 1
    ;;
esac

case "${SCENARIO}" in
  read-heavy|write-heavy|update-heavy)
    ;;
  *)
    echo "Unsupported scenario: ${SCENARIO}"
    exit 1
    ;;
esac

command -v k6 >/dev/null 2>&1 || {
  echo "Error: k6 not found."
  exit 1
}

mkdir -p "${RESULT_DIR}"

for run in $(seq 1 "${REPEAT}"); do
  timestamp="$(date +%Y%m%d-%H%M%S)"
  summary_file="${RESULT_DIR}/${SCENARIO}-${timestamp}-run${run}.json"

  echo "=== API Benchmark ==="
  echo "Target: ${TARGET}"
  echo "Scenario: ${SCENARIO}"
  echo "Run: ${run}/${REPEAT}"
  echo "Base URL: ${BASE_URL}"
  echo "Summary: ${summary_file}"
  echo ""

  BASE_URL="${BASE_URL}" \
  k6 run \
    --summary-export "${summary_file}" \
    "${ROOT_DIR}/k6/mysql-vs-postgres/scenarios/${SCENARIO}.js"
done

echo ""
echo "API benchmark complete. Results in ${RESULT_DIR}"
