#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 3 ]]; then
  echo "Usage: delete-engine-metrics.sh <mysql|postgres> <scenario> <run_id>"
  exit 1
fi

DATABASE="$1"
SCENARIO="$2"
RUN_ID="$3"
PUSHGATEWAY_URL="${PUSHGATEWAY_URL:-http://127.0.0.1:19092}"

curl --silent --show-error --fail -X DELETE \
  "${PUSHGATEWAY_URL}/metrics/job/engine_benchmark/run_id/${RUN_ID}/database/${DATABASE}/scenario/${SCENARIO}"
