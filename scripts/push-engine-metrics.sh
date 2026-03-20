#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 5 ]]; then
  echo "Usage: push-engine-metrics.sh <mysql|postgres> <scenario> <run_id> <throughput_tps> <latency_ms>"
  exit 1
fi

DATABASE="$1"
SCENARIO="$2"
RUN_ID="$3"
THROUGHPUT_TPS="$4"
LATENCY_MS="$5"
PUSHGATEWAY_URL="${PUSHGATEWAY_URL:-http://127.0.0.1:19092}"

cat <<EOF | curl --silent --show-error --fail --data-binary @- \
  "${PUSHGATEWAY_URL}/metrics/job/engine_benchmark/run_id/${RUN_ID}/database/${DATABASE}/scenario/${SCENARIO}"
# TYPE engine_benchmark_throughput_tps gauge
engine_benchmark_throughput_tps ${THROUGHPUT_TPS}
# TYPE engine_benchmark_latency_avg_ms gauge
engine_benchmark_latency_avg_ms ${LATENCY_MS}
EOF
